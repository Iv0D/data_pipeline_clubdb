import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import psycopg2
from sqlalchemy import create_engine

# Page configuration
st.set_page_config(
    page_title="Club Analytics Dashboard",
    page_icon="🏆",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Database connection
@st.cache_resource
def get_db_connection():
    engine = create_engine('postgresql://postgres:postgres@localhost:5432/club_analytics')
    return engine

# Load data functions
@st.cache_data
def load_ticket_sales():
    engine = get_db_connection()
    query = """
    SELECT 
        fts.*,
        dm.full_name,
        dm.status as member_status,
        de.event_name,
        de.event_type,
        de.sport,
        de.location,
        dd.full_date as sale_date_full,
        dd.year,
        dd.month,
        dd.month_name,
        dd.quarter
    FROM analytics.fact_ticket_sales fts
    LEFT JOIN analytics.dim_member dm ON fts.member_key = dm.member_key
    LEFT JOIN analytics.dim_event de ON fts.event_key = de.event_key
    LEFT JOIN analytics.dim_date dd ON fts.date_key = dd.date_key
    ORDER BY fts.sale_date DESC
    """
    return pd.read_sql(query, engine)

@st.cache_data
def load_dues_payments():
    engine = get_db_connection()
    query = """
    SELECT 
        fdp.*,
        dm.full_name,
        dm.status as member_status,
        dd.full_date as payment_date_full,
        dd.year,
        dd.month,
        dd.month_name,
        dd.quarter
    FROM analytics.fact_dues_payments fdp
    LEFT JOIN analytics.dim_member dm ON fdp.member_key = dm.member_key
    LEFT JOIN analytics.dim_date dd ON fdp.date_key = dd.date_key
    ORDER BY fdp.payment_date DESC
    """
    return pd.read_sql(query, engine)

@st.cache_data
def load_attendance():
    engine = get_db_connection()
    query = """
    SELECT 
        fa.*,
        dm.full_name,
        dm.status as member_status,
        de.event_name,
        de.event_type,
        de.sport,
        de.location,
        dd.full_date as attendance_date_full,
        dd.year,
        dd.month,
        dd.month_name,
        dd.quarter
    FROM analytics.fact_attendance fa
    LEFT JOIN analytics.dim_member dm ON fa.member_key = dm.member_key
    LEFT JOIN analytics.dim_event de ON fa.event_key = de.event_key
    LEFT JOIN analytics.dim_date dd ON fa.date_key = dd.date_key
    ORDER BY fa.attendance_date DESC
    """
    return pd.read_sql(query, engine)

@st.cache_data
def load_members():
    engine = get_db_connection()
    query = "SELECT * FROM analytics.dim_member ORDER BY registration_date DESC"
    return pd.read_sql(query, engine)

@st.cache_data
def load_events():
    engine = get_db_connection()
    query = "SELECT * FROM analytics.dim_event ORDER BY event_date DESC"
    return pd.read_sql(query, engine)

# Main dashboard
def main():
    st.title("🏆 Club Analytics Dashboard")
    st.markdown("---")
    
    # Load data
    with st.spinner("Loading data..."):
        ticket_sales = load_ticket_sales()
        dues_payments = load_dues_payments()
        attendance = load_attendance()
        members = load_members()
        events = load_events()
    
    # Sidebar filters
    st.sidebar.header("Filters")
    
    # Date range filter
    min_date = min(ticket_sales['sale_date'].min(), dues_payments['payment_date'].min())
    max_date = max(ticket_sales['sale_date'].max(), dues_payments['payment_date'].max())
    
    date_range = st.sidebar.date_input(
        "Date Range",
        value=(min_date, max_date),
        min_value=min_date,
        max_value=max_date
    )
    
    # Event type filter
    event_types = st.sidebar.multiselect(
        "Event Types",
        options=['EVENT', 'PARTIDO', 'ACTIVIDAD'],
        default=['EVENT', 'PARTIDO', 'ACTIVIDAD']
    )
    
    # Member status filter
    member_statuses = st.sidebar.multiselect(
        "Member Status",
        options=['Active', 'Inactive'],
        default=['Active', 'Inactive']
    )
    
    # Apply filters
    if len(date_range) == 2:
        start_date, end_date = date_range
        ticket_sales = ticket_sales[
            (ticket_sales['sale_date'] >= start_date) & 
            (ticket_sales['sale_date'] <= end_date)
        ]
        dues_payments = dues_payments[
            (dues_payments['payment_date'] >= start_date) & 
            (dues_payments['payment_date'] <= end_date)
        ]
    
    ticket_sales = ticket_sales[ticket_sales['event_type'].isin(event_types)]
    dues_payments = dues_payments[dues_payments['member_status'].isin(member_statuses)]
    
    # Key Metrics
    st.header("📊 Key Metrics")
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        total_revenue = ticket_sales['ticket_price'].sum()
        st.metric(
            label="Total Ticket Revenue",
            value=f"${total_revenue:,.2f}",
            delta=f"{len(ticket_sales)} tickets sold"
        )
    
    with col2:
        total_dues = dues_payments[dues_payments['is_paid']]['payment_amount'].sum()
        st.metric(
            label="Total Dues Collected",
            value=f"${total_dues:,.2f}",
            delta=f"{len(dues_payments[dues_payments['is_paid']])} payments"
        )
    
    with col3:
        active_members = len(members[members['status_active']])
        st.metric(
            label="Active Members",
            value=active_members,
            delta=f"{len(members)} total members"
        )
    
    with col4:
        avg_revenue_per_member = total_dues / active_members if active_members > 0 else 0
        st.metric(
            label="Avg Revenue Per Member",
            value=f"${avg_revenue_per_member:,.2f}",
            delta="ARPPM"
        )
    
    st.markdown("---")
    
    # Charts
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("📈 Revenue Trends")
        
        # Monthly revenue
        monthly_revenue = ticket_sales.groupby(['year', 'month_name'])['ticket_price'].sum().reset_index()
        monthly_revenue['period'] = monthly_revenue['year'].astype(str) + '-' + monthly_revenue['month_name']
        
        fig_revenue = px.line(
            monthly_revenue, 
            x='period', 
            y='ticket_price',
            title="Monthly Ticket Revenue",
            labels={'ticket_price': 'Revenue ($)', 'period': 'Month'}
        )
        st.plotly_chart(fig_revenue, use_container_width=True)
    
    with col2:
        st.subheader("🎯 Event Performance")
        
        # Event type revenue
        event_revenue = ticket_sales.groupby('event_type')['ticket_price'].sum().reset_index()
        
        fig_event = px.pie(
            event_revenue,
            values='ticket_price',
            names='event_type',
            title="Revenue by Event Type"
        )
        st.plotly_chart(fig_event, use_container_width=True)
    
    # Member Analysis
    st.subheader("👥 Member Analysis")
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Member registration trends
        member_registrations = members.groupby(['registration_year', 'registration_month']).size().reset_index()
        member_registrations['period'] = member_registrations['registration_year'].astype(str) + '-' + member_registrations['registration_month'].astype(str).str.zfill(2)
        
        fig_members = px.bar(
            member_registrations,
            x='period',
            y=0,
            title="Member Registrations by Month",
            labels={0: 'New Members', 'period': 'Month'}
        )
        st.plotly_chart(fig_members, use_container_width=True)
    
    with col2:
        # Payment status distribution
        payment_status = dues_payments['payment_status'].value_counts().reset_index()
        
        fig_payments = px.bar(
            payment_status,
            x='payment_status',
            y='count',
            title="Payment Status Distribution",
            labels={'count': 'Number of Payments', 'payment_status': 'Status'}
        )
        st.plotly_chart(fig_payments, use_container_width=True)
    
    # Data Tables
    st.subheader("📋 Detailed Data")
    
    tab1, tab2, tab3, tab4 = st.tabs(["Ticket Sales", "Dues Payments", "Members", "Events"])
    
    with tab1:
        st.dataframe(
            ticket_sales[['full_name', 'event_name', 'event_type', 'ticket_price', 'sale_date']].head(20),
            use_container_width=True
        )
    
    with tab2:
        st.dataframe(
            dues_payments[['full_name', 'payment_amount', 'payment_status', 'payment_date']].head(20),
            use_container_width=True
        )
    
    with tab3:
        st.dataframe(
            members[['full_name', 'status', 'registration_date', 'member_tenure_months']].head(20),
            use_container_width=True
        )
    
    with tab4:
        st.dataframe(
            events[['event_name', 'event_type', 'sport', 'event_date', 'location']].head(20),
            use_container_width=True
        )
    
    # Footer
    st.markdown("---")
    st.markdown("**Club Analytics Dashboard** - Powered by dbt, Airflow, and Streamlit")

if __name__ == "__main__":
    main()


