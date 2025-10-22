#!/usr/bin/env python3
"""
Idempotent Batch Loader for Club Analytics Pipeline

This script provides robust, idempotent batch loading capabilities using:
- COPY FROM for efficient bulk loading
- ON CONFLICT for idempotent operations
- Proper error handling and logging
- Support for incremental and full loads
"""

import os
import sys
import logging
import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
from sqlalchemy import create_engine, text
from datetime import datetime
from typing import Dict, List, Any, Optional
import argparse
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('batch_loader.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


class IdempotentBatchLoader:
    """Handles idempotent batch loading operations"""
    
    def __init__(self, connection_string: str):
        """Initialize the batch loader with database connection"""
        self.connection_string = connection_string
        self.engine = create_engine(connection_string)
        
    def create_staging_table(self, table_name: str, schema: str, columns: List[str], 
                           primary_key: str) -> str:
        """Create a staging table for batch loading"""
        staging_table = f"{table_name}_staging_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        # Create staging table with same structure as target table
        create_staging_sql = f"""
        CREATE TEMP TABLE {staging_table} (
            LIKE {schema}.{table_name}
        );
        """
        
        with self.engine.connect() as conn:
            conn.execute(text(create_staging_sql))
            conn.commit()
            
        logger.info(f"Created staging table: {staging_table}")
        return staging_table
    
    def load_from_csv(self, csv_path: str, staging_table: str, schema: str) -> int:
        """Load data from CSV file into staging table using COPY FROM"""
        if not os.path.exists(csv_path):
            raise FileNotFoundError(f"CSV file not found: {csv_path}")
        
        # Get raw connection for COPY operations
        raw_conn = psycopg2.connect(self.connection_string.replace('postgresql://', 'postgresql://'))
        cursor = raw_conn.cursor()
        
        try:
            # Use COPY FROM for efficient bulk loading
            with open(csv_path, 'r') as f:
                cursor.copy_expert(
                    f"COPY {staging_table} FROM STDIN WITH CSV HEADER",
                    f
                )
            
            raw_conn.commit()
            
            # Get row count
            cursor.execute(f"SELECT COUNT(*) FROM {staging_table}")
            row_count = cursor.fetchone()[0]
            
            logger.info(f"Loaded {row_count} rows from {csv_path} into {staging_table}")
            return row_count
            
        except Exception as e:
            raw_conn.rollback()
            logger.error(f"Error loading CSV {csv_path}: {str(e)}")
            raise
        finally:
            cursor.close()
            raw_conn.close()
    
    def load_from_dataframe(self, df: pd.DataFrame, staging_table: str, schema: str) -> int:
        """Load data from DataFrame into staging table"""
        try:
            # Use pandas to_sql for DataFrame loading
            df.to_sql(
                staging_table,
                self.engine,
                schema=schema,
                if_exists='replace',
                index=False,
                method='multi'
            )
            
            row_count = len(df)
            logger.info(f"Loaded {row_count} rows from DataFrame into {staging_table}")
            return row_count
            
        except Exception as e:
            logger.error(f"Error loading DataFrame into {staging_table}: {str(e)}")
            raise
    
    def upsert_from_staging(self, staging_table: str, target_table: str, 
                          schema: str, primary_key: str, 
                          update_columns: Optional[List[str]] = None) -> Dict[str, int]:
        """Perform idempotent upsert from staging table to target table"""
        
        with self.engine.connect() as conn:
            try:
                # Get column information
                columns_query = f"""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_schema = '{schema}' 
                AND table_name = '{target_table}'
                ORDER BY ordinal_position
                """
                
                columns_result = conn.execute(text(columns_query))
                all_columns = [row[0] for row in columns_result]
                
                # If update_columns not specified, update all non-primary key columns
                if update_columns is None:
                    update_columns = [col for col in all_columns if col != primary_key]
                
                # Build the upsert query
                columns_str = ', '.join(all_columns)
                excluded_columns = ', '.join([f"{col} = EXCLUDED.{col}" for col in update_columns])
                
                upsert_sql = f"""
                INSERT INTO {schema}.{target_table} ({columns_str})
                SELECT {columns_str} FROM {staging_table}
                ON CONFLICT ({primary_key}) 
                DO UPDATE SET {excluded_columns}
                """
                
                # Execute upsert
                result = conn.execute(text(upsert_sql))
                conn.commit()
                
                # Get statistics
                stats_query = f"""
                SELECT 
                    (SELECT COUNT(*) FROM {staging_table}) as total_rows,
                    (SELECT COUNT(*) FROM {schema}.{target_table}) as target_rows
                """
                
                stats_result = conn.execute(text(stats_query))
                stats = stats_result.fetchone()
                
                logger.info(f"Upsert completed: {stats[0]} rows processed, {stats[1]} total rows in target")
                
                return {
                    'rows_processed': stats[0],
                    'total_rows_in_target': stats[1]
                }
                
            except Exception as e:
                conn.rollback()
                logger.error(f"Error during upsert: {str(e)}")
                raise
    
    def batch_load_csv(self, csv_path: str, target_table: str, schema: str, 
                      primary_key: str, update_columns: Optional[List[str]] = None) -> Dict[str, Any]:
        """Complete batch load process from CSV file"""
        logger.info(f"Starting batch load: {csv_path} -> {schema}.{target_table}")
        
        try:
            # Create staging table
            staging_table = self.create_staging_table(target_table, schema, [], primary_key)
            
            # Load data into staging
            rows_loaded = self.load_from_csv(csv_path, staging_table, schema)
            
            # Perform upsert
            upsert_stats = self.upsert_from_staging(
                staging_table, target_table, schema, primary_key, update_columns
            )
            
            # Clean up staging table
            with self.engine.connect() as conn:
                conn.execute(text(f"DROP TABLE IF EXISTS {staging_table}"))
                conn.commit()
            
            result = {
                'success': True,
                'csv_path': csv_path,
                'target_table': f"{schema}.{target_table}",
                'rows_loaded': rows_loaded,
                'upsert_stats': upsert_stats,
                'timestamp': datetime.now().isoformat()
            }
            
            logger.info(f"Batch load completed successfully: {result}")
            return result
            
        except Exception as e:
            logger.error(f"Batch load failed: {str(e)}")
            return {
                'success': False,
                'error': str(e),
                'csv_path': csv_path,
                'target_table': f"{schema}.{target_table}",
                'timestamp': datetime.now().isoformat()
            }
    
    def batch_load_dataframe(self, df: pd.DataFrame, target_table: str, schema: str, 
                           primary_key: str, update_columns: Optional[List[str]] = None) -> Dict[str, Any]:
        """Complete batch load process from DataFrame"""
        logger.info(f"Starting batch load: DataFrame -> {schema}.{target_table}")
        
        try:
            # Create staging table
            staging_table = self.create_staging_table(target_table, schema, [], primary_key)
            
            # Load data into staging
            rows_loaded = self.load_from_dataframe(df, staging_table, schema)
            
            # Perform upsert
            upsert_stats = self.upsert_from_staging(
                staging_table, target_table, schema, primary_key, update_columns
            )
            
            # Clean up staging table
            with self.engine.connect() as conn:
                conn.execute(text(f"DROP TABLE IF EXISTS {staging_table}"))
                conn.commit()
            
            result = {
                'success': True,
                'target_table': f"{schema}.{target_table}",
                'rows_loaded': rows_loaded,
                'upsert_stats': upsert_stats,
                'timestamp': datetime.now().isoformat()
            }
            
            logger.info(f"Batch load completed successfully: {result}")
            return result
            
        except Exception as e:
            logger.error(f"Batch load failed: {str(e)}")
            return {
                'success': False,
                'error': str(e),
                'target_table': f"{schema}.{target_table}",
                'timestamp': datetime.now().isoformat()
            }


def main():
    """Main function for command-line usage"""
    parser = argparse.ArgumentParser(description='Idempotent Batch Loader')
    parser.add_argument('--csv-path', required=True, help='Path to CSV file')
    parser.add_argument('--target-table', required=True, help='Target table name')
    parser.add_argument('--schema', default='raw', help='Target schema')
    parser.add_argument('--primary-key', required=True, help='Primary key column')
    parser.add_argument('--update-columns', nargs='*', help='Columns to update on conflict')
    parser.add_argument('--connection-string', 
                       default='postgresql://postgres:postgres@localhost:5432/club_analytics',
                       help='Database connection string')
    
    args = parser.parse_args()
    
    # Initialize batch loader
    loader = IdempotentBatchLoader(args.connection_string)
    
    # Perform batch load
    result = loader.batch_load_csv(
        csv_path=args.csv_path,
        target_table=args.target_table,
        schema=args.schema,
        primary_key=args.primary_key,
        update_columns=args.update_columns
    )
    
    # Print result
    if result['success']:
        print(f"✅ Batch load successful: {result['rows_loaded']} rows loaded")
        print(f"📊 Upsert stats: {result['upsert_stats']}")
    else:
        print(f"❌ Batch load failed: {result['error']}")
        sys.exit(1)


if __name__ == "__main__":
    main()
