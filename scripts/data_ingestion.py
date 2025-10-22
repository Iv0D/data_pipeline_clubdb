#!/usr/bin/env python3
"""
Club Analytics Data Ingestion Script
Simulates daily CSV generation for tickets and dues data
"""

import pandas as pd
import numpy as np
import os
from datetime import datetime, timedelta
import random
from pathlib import Path

def generate_ticket_data(date, num_records=50):
    """Generate simulated ticket sales data"""
    
    # Sample event types and prices
    event_types = ['EVENT', 'PARTIDO', 'ACTIVIDAD']
    event_prices = {
        'EVENT': (800, 2000),
        'PARTIDO': (1000, 2500),
        'ACTIVIDAD': (500, 1500)
    }
    
    # Sample member IDs (assuming 15 members from the original data)
    member_ids = list(range(1, 16))
    
    tickets = []
    for i in range(num_records):
        event_type = random.choice(event_types)
        min_price, max_price = event_prices[event_type]
        
        ticket = {
            'identrada': f"{date.strftime('%Y%m%d')}{i+1:03d}",
            'idsocio': random.choice(member_ids),
            'precio': random.randint(min_price, max_price),
            'idevento': random.randint(1, 15) if event_type == 'EVENT' else None,
            'idpartido': random.randint(1, 15) if event_type == 'PARTIDO' else None,
            'idactividad': random.randint(1, 15) if event_type == 'ACTIVIDAD' else None
        }
        tickets.append(ticket)
    
    return pd.DataFrame(tickets)

def generate_dues_data(date, num_records=30):
    """Generate simulated dues payment data"""
    
    # Sample member IDs
    member_ids = list(range(1, 16))
    
    dues = []
    for i in range(num_records):
        # Generate due date (past, present, or future)
        due_date_offset = random.randint(-30, 30)
        due_date = date + timedelta(days=due_date_offset)
        
        # Payment status (80% paid, 20% pending)
        is_paid = random.random() < 0.8
        
        dues_payment = {
            'idcuota': f"{date.strftime('%Y%m%d')}{i+1:03d}",
            'idsocio': random.choice(member_ids),
            'precio': random.randint(4000, 6000),  # Monthly dues between 4000-6000
            'fechavenc': due_date.strftime('%Y-%m-%d'),
            'estado': 1 if is_paid else 0
        }
        dues.append(dues_payment)
    
    return pd.DataFrame(dues)

def generate_attendance_data(date, num_records=40):
    """Generate simulated attendance data"""
    
    member_ids = list(range(1, 16))
    event_ids = list(range(1, 16))
    
    attendance = []
    for i in range(num_records):
        attendance_record = {
            'attendance_id': f"{date.strftime('%Y%m%d')}{i+1:03d}",
            'member_id': random.choice(member_ids),
            'event_id': random.choice(event_ids),
            'attendance_date': date.strftime('%Y-%m-%d'),
            'attendance_time': f"{random.randint(8, 22):02d}:{random.randint(0, 59):02d}:00",
            'event_type': random.choice(['EVENT', 'PARTIDO', 'ACTIVIDAD'])
        }
        attendance.append(attendance_record)
    
    return pd.DataFrame(attendance)

def main():
    """Main function to generate daily CSV files"""
    
    # Create data directories
    data_dir = Path('data')
    raw_dir = data_dir / 'raw'
    metrics_dir = data_dir / 'metrics'
    
    raw_dir.mkdir(parents=True, exist_ok=True)
    metrics_dir.mkdir(parents=True, exist_ok=True)
    
    # Generate data for today
    today = datetime.now()
    
    print(f"Generating data for {today.strftime('%Y-%m-%d')}")
    
    # Generate ticket sales data
    tickets_df = generate_ticket_data(today)
    tickets_file = raw_dir / f"tickets_{today.strftime('%Y%m%d')}.csv"
    tickets_df.to_csv(tickets_file, index=False)
    print(f"Generated {len(tickets_df)} ticket records: {tickets_file}")
    
    # Generate dues payment data
    dues_df = generate_dues_data(today)
    dues_file = raw_dir / f"dues_{today.strftime('%Y%m%d')}.csv"
    dues_df.to_csv(dues_file, index=False)
    print(f"Generated {len(dues_df)} dues records: {dues_file}")
    
    # Generate attendance data
    attendance_df = generate_attendance_data(today)
    attendance_file = raw_dir / f"attendance_{today.strftime('%Y%m%d')}.csv"
    attendance_df.to_csv(attendance_file, index=False)
    print(f"Generated {len(attendance_df)} attendance records: {attendance_file}")
    
    # Generate summary metrics
    summary_metrics = {
        'date': today.strftime('%Y-%m-%d'),
        'total_tickets': len(tickets_df),
        'total_ticket_revenue': tickets_df['precio'].sum(),
        'total_dues': len(dues_df),
        'total_dues_revenue': dues_df[dues_df['estado'] == 1]['precio'].sum(),
        'total_attendance': len(attendance_df),
        'files_generated': 3
    }
    
    summary_file = metrics_dir / f"daily_summary_{today.strftime('%Y%m%d')}.json"
    pd.DataFrame([summary_metrics]).to_json(summary_file, orient='records', indent=2)
    print(f"Generated summary metrics: {summary_file}")
    
    print("Data generation completed successfully!")

if __name__ == "__main__":
    main()


