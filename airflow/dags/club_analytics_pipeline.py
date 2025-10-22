from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
import pandas as pd
import os

# Default arguments
default_args = {
    'owner': 'club_analytics',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# DAG definition
dag = DAG(
    'club_analytics_pipeline',
    default_args=default_args,
    description='Club Analytics Pipeline: Data Ingestion, Transformation, and Quality Checks',
    schedule_interval='@daily',
    catchup=False,
    tags=['analytics', 'club', 'dbt', 'data-quality'],
)

# Task 1: Seed raw data from CSV files
def seed_raw_data():
    """Simulate daily CSV ingestion and load into raw tables"""
    postgres_hook = PostgresHook(postgres_conn_id='postgres_default')
    
    # Create raw schema if it doesn't exist
    postgres_hook.run("CREAR SCHEMA SI NO EXISTE raw;")
    
    # Load CSV data into raw tables
    csv_files = ['tickets', 'dues']
    
    for file_type in csv_files:
        csv_path = f'/opt/airflow/data/raw/{file_type}_{datetime.now().strftime("%Y%m%d")}.csv'
        
        if os.path.exists(csv_path):
            df = pd.read_csv(csv_path)
            
            if file_type == 'tickets':
                # Load ticket data
                df.to_sql('entrada', postgres_hook.get_conn(), 
                         schema='raw', if_exists='append', index=False)
            elif file_type == 'dues':
                # Load dues data
                df.to_sql('cuota', postgres_hook.get_conn(), 
                         schema='raw', if_exists='append', index=False)
            
            print(f"Loaded {len(df)} records from {csv_path}")
        else:
            print(f"CSV file {csv_path} not found, skipping...")

seed_task = PythonOperator(
    task_id='seed_raw_data',
    python_callable=seed_raw_data,
    dag=dag,
)

# Task 2: Run dbt models
dbt_run_task = BashOperator(
    task_id='dbt_run',
    bash_command='cd /opt/airflow/dbt && dbt run --profiles-dir /opt/airflow',
    dag=dag,
)

# Task 3: Run dbt tests
dbt_test_task = BashOperator(
    task_id='dbt_test',
    bash_command='cd /opt/airflow/dbt && dbt test --profiles-dir /opt/airflow',
    dag=dag,
)

# Task 4: Data quality checks with Soda
def run_soda_checks():
    """Run Soda data quality checks"""
    os.system('cd /opt/airflow && soda scan -d postgres_local -c configuration.yml tables/')
    print("Soda data quality checks completed")

soda_task = PythonOperator(
    task_id='soda_data_quality',
    python_callable=run_soda_checks,
    dag=dag,
)

# Task 5: Calculate daily metrics
def calculate_daily_metrics():
    """Calculate and export daily metrics"""
    postgres_hook = PostgresHook(postgres_conn_id='postgres_default')
    
    # Calculate MRR (Monthly Recurring Revenue)
    mrr_query = """
    SELECT 
        SUM(payment_amount) as mrr
    FROM analytics.fact_dues_payments 
    WHERE payment_date = CURRENT_DATE AND is_paid = true
    """
    mrr_result = postgres_hook.get_first(mrr_query)
    mrr = mrr_result[0] if mrr_result else 0
    
    # Calculate ARPPM (Average Revenue Per Paying Member)
    arppm_query = """
    SELECT 
        AVG(payment_amount) as arppm
    FROM analytics.fact_dues_payments 
    WHERE payment_date = CURRENT_DATE AND is_paid = true
    """
    arppm_result = postgres_hook.get_first(arppm_query)
    arppm = arppm_result[0] if arppm_result else 0
    
    # Calculate event revenue
    event_revenue_query = """
    SELECT 
        SUM(ticket_price) as event_revenue
    FROM analytics.fact_ticket_sales 
    WHERE sale_date = CURRENT_DATE
    """
    event_revenue_result = postgres_hook.get_first(event_revenue_query)
    event_revenue = event_revenue_result[0] if event_revenue_result else 0
    
    # Calculate retention rate
    retention_query = """
    WITH active_members AS (
        SELECT COUNT(*) as active_count
        FROM analytics.dim_member 
        WHERE status_active = true
    ),
    new_members AS (
        SELECT COUNT(*) as new_count
        FROM analytics.dim_member 
        WHERE registration_date = CURRENT_DATE
    )
    SELECT 
        (active_count - new_count)::float / NULLIF(active_count, 0) as retention_rate
    FROM active_members, new_members
    """
    retention_result = postgres_hook.get_first(retention_query)
    retention_rate = retention_result[0] if retention_result else 0
    
    # Export metrics to file
    metrics = {
        'date': datetime.now().strftime('%Y-%m-%d'),
        'mrr': mrr,
        'arppm': arppm,
        'event_revenue': event_revenue,
        'retention_rate': retention_rate
    }
    
    metrics_df = pd.DataFrame([metrics])
    metrics_df.to_csv(f'/opt/airflow/data/metrics/daily_metrics_{datetime.now().strftime("%Y%m%d")}.csv', 
                     index=False)
    
    print(f"Daily metrics calculated and exported: {metrics}")

metrics_task = PythonOperator(
    task_id='calculate_daily_metrics',
    python_callable=calculate_daily_metrics,
    dag=dag,
)

# Task 6: Generate data lineage report
def generate_lineage_report():
    """Generate data lineage report"""
    os.system('cd /opt/airflow/dbt && dbt docs generate --profiles-dir /opt/airflow')
    print("Data lineage report generated")

lineage_task = PythonOperator(
    task_id='generate_lineage_report',
    python_callable=generate_lineage_report,
    dag=dag,
)

# Define task dependencies
seed_task >> dbt_run_task >> dbt_test_task >> soda_task >> metrics_task >> lineage_task


