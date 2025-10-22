import pytest
import pandas as pd
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path

# Add the scripts directory to the path
sys.path.append(str(Path(__file__).parent.parent / 'scripts'))

from data_ingestion import generate_ticket_data, generate_dues_data, generate_attendance_data

class TestDataIngestion:
    """Test cases for data ingestion functions"""
    
    def test_generate_ticket_data(self):
        """Test ticket data generation"""
        test_date = datetime(2024, 1, 15)
        tickets_df = generate_ticket_data(test_date, num_records=10)
        
        # Check basic structure
        assert len(tickets_df) == 10
        assert 'identrada' in tickets_df.columns
        assert 'idsocio' in tickets_df.columns
        assert 'precio' in tickets_df.columns
        assert 'idevento' in tickets_df.columns
        assert 'idpartido' in tickets_df.columns
        assert 'idactividad' in tickets_df.columns
        
        # Check data types and ranges
        assert tickets_df['idsocio'].between(1, 15).all()
        assert tickets_df['precio'].between(500, 2500).all()
        
        # Check that only one event type is set per record
        event_columns = ['idevento', 'idpartido', 'idactividad']
        for _, row in tickets_df.iterrows():
            non_null_count = sum(1 for col in event_columns if pd.notna(row[col]))
            assert non_null_count == 1, f"Each ticket should have exactly one event type, got {non_null_count}"
    
    def test_generate_dues_data(self):
        """Test dues data generation"""
        test_date = datetime(2024, 1, 15)
        dues_df = generate_dues_data(test_date, num_records=10)
        
        # Check basic structure
        assert len(dues_df) == 10
        assert 'idcuota' in dues_df.columns
        assert 'idsocio' in dues_df.columns
        assert 'precio' in dues_df.columns
        assert 'fechavenc' in dues_df.columns
        assert 'estado' in dues_df.columns
        
        # Check data types and ranges
        assert dues_df['idsocio'].between(1, 15).all()
        assert dues_df['precio'].between(4000, 6000).all()
        assert dues_df['estado'].isin([0, 1]).all()
        
        # Check date format
        for date_str in dues_df['fechavenc']:
            datetime.strptime(date_str, '%Y-%m-%d')
    
    def test_generate_attendance_data(self):
        """Test attendance data generation"""
        test_date = datetime(2024, 1, 15)
        attendance_df = generate_attendance_data(test_date, num_records=10)
        
        # Check basic structure
        assert len(attendance_df) == 10
        assert 'attendance_id' in attendance_df.columns
        assert 'member_id' in attendance_df.columns
        assert 'event_id' in attendance_df.columns
        assert 'attendance_date' in attendance_df.columns
        assert 'attendance_time' in attendance_df.columns
        assert 'event_type' in attendance_df.columns
        
        # Check data types and ranges
        assert attendance_df['member_id'].between(1, 15).all()
        assert attendance_df['event_id'].between(1, 15).all()
        assert attendance_df['event_type'].isin(['EVENT', 'PARTIDO', 'ACTIVIDAD']).all()
        
        # Check date format
        for date_str in attendance_df['attendance_date']:
            datetime.strptime(date_str, '%Y-%m-%d')
        
        # Check time format
        for time_str in attendance_df['attendance_time']:
            datetime.strptime(time_str, '%H:%M:%S')
    
    def test_data_consistency(self):
        """Test data consistency across different generation functions"""
        test_date = datetime(2024, 1, 15)
        
        tickets_df = generate_ticket_data(test_date, num_records=5)
        dues_df = generate_dues_data(test_date, num_records=5)
        attendance_df = generate_attendance_data(test_date, num_records=5)
        
        # Check that member IDs are consistent across all datasets
        ticket_members = set(tickets_df['idsocio'])
        dues_members = set(dues_df['idsocio'])
        attendance_members = set(attendance_df['member_id'])
        
        # All member IDs should be in the valid range
        valid_members = set(range(1, 16))
        assert ticket_members.issubset(valid_members)
        assert dues_members.issubset(valid_members)
        assert attendance_members.issubset(valid_members)
    
    def test_csv_generation(self):
        """Test CSV file generation"""
        from data_ingestion import main
        
        # Create test data directory
        test_data_dir = Path('test_data')
        test_data_dir.mkdir(exist_ok=True)
        
        # Change to test directory
        original_cwd = os.getcwd()
        os.chdir(test_data_dir)
        
        try:
            # Run the main function
            main()
            
            # Check that files were created
            today = datetime.now()
            expected_files = [
                f"data/raw/tickets_{today.strftime('%Y%m%d')}.csv",
                f"data/raw/dues_{today.strftime('%Y%m%d')}.csv",
                f"data/raw/attendance_{today.strftime('%Y%m%d')}.csv",
                f"data/metrics/daily_summary_{today.strftime('%Y%m%d')}.json"
            ]
            
            for file_path in expected_files:
                assert os.path.exists(file_path), f"Expected file {file_path} not found"
                
                # Check file is not empty
                assert os.path.getsize(file_path) > 0, f"File {file_path} is empty"
        
        finally:
            # Clean up and return to original directory
            os.chdir(original_cwd)
            import shutil
            shutil.rmtree(test_data_dir, ignore_errors=True)

class TestDataValidation:
    """Test cases for data validation"""
    
    def test_ticket_price_validation(self):
        """Test ticket price validation"""
        test_date = datetime(2024, 1, 15)
        tickets_df = generate_ticket_data(test_date, num_records=100)
        
        # All prices should be positive
        assert (tickets_df['precio'] > 0).all()
        
        # Prices should be within reasonable range
        assert (tickets_df['precio'] <= 10000).all()
    
    def test_dues_amount_validation(self):
        """Test dues amount validation"""
        test_date = datetime(2024, 1, 15)
        dues_df = generate_dues_data(test_date, num_records=100)
        
        # All amounts should be positive
        assert (dues_df['precio'] > 0).all()
        
        # Amounts should be within reasonable range
        assert (dues_df['precio'] <= 10000).all()
    
    def test_date_validation(self):
        """Test date validation"""
        test_date = datetime(2024, 1, 15)
        dues_df = generate_dues_data(test_date, num_records=100)
        
        # All dates should be valid
        for date_str in dues_df['fechavenc']:
            parsed_date = datetime.strptime(date_str, '%Y-%m-%d')
            assert parsed_date is not None

if __name__ == "__main__":
    pytest.main([__file__])


