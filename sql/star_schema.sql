-- Star Schema for Club Analytics
-- Converting OLTP to OLAP with facts and dimensions

-- ===== DIMENSIONS =====

-- Date dimension
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day_of_year INT NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN DEFAULT FALSE,
    fiscal_year INT,
    fiscal_quarter INT
);

-- Member dimension
CREATE TABLE dim_member (
    member_key INT PRIMARY KEY,
    member_id INT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(201) NOT NULL,
    document VARCHAR(20) NOT NULL,
    registration_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    status_active BOOLEAN NOT NULL,
    registration_year INT NOT NULL,
    registration_month INT NOT NULL,
    member_tenure_days INT NOT NULL,
    member_tenure_months INT NOT NULL
);

-- Event dimension
CREATE TABLE dim_event (
    event_key INT PRIMARY KEY,
    event_id INT NOT NULL,
    event_name VARCHAR(100) NOT NULL,
    event_type VARCHAR(20) NOT NULL, -- 'EVENT', 'PARTIDO', 'ACTIVIDAD'
    sport VARCHAR(100),
    location VARCHAR(100) NOT NULL,
    event_date DATE NOT NULL,
    event_time TIME NOT NULL,
    event_datetime TIMESTAMP NOT NULL,
    event_year INT NOT NULL,
    event_month INT NOT NULL,
    event_quarter INT NOT NULL,
    is_weekend_event BOOLEAN NOT NULL,
    venue_type VARCHAR(50) -- 'Estadio', 'Salón', 'Auditorio', etc.
);

-- ===== FACTS =====

-- Ticket sales fact
CREATE TABLE fact_ticket_sales (
    ticket_sale_key BIGINT PRIMARY KEY,
    member_key INT NOT NULL,
    event_key INT NOT NULL,
    date_key INT NOT NULL,
    ticket_id INT NOT NULL,
    ticket_price DECIMAL(10,2) NOT NULL,
    sale_date DATE NOT NULL,
    sale_time TIME NOT NULL,
    sale_datetime TIMESTAMP NOT NULL,
    event_type VARCHAR(20) NOT NULL,
    FOREIGN KEY (member_key) REFERENCES dim_member(member_key),
    FOREIGN KEY (event_key) REFERENCES dim_event(event_key),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

-- Dues payments fact
CREATE TABLE fact_dues_payments (
    dues_payment_key BIGINT PRIMARY KEY,
    member_key INT NOT NULL,
    date_key INT NOT NULL,
    payment_id INT NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    due_date DATE NOT NULL,
    payment_date DATE NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    is_paid BOOLEAN NOT NULL,
    is_overdue BOOLEAN NOT NULL,
    days_overdue INT DEFAULT 0,
    payment_month INT NOT NULL,
    payment_year INT NOT NULL,
    FOREIGN KEY (member_key) REFERENCES dim_member(member_key),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

-- Attendance fact
CREATE TABLE fact_attendance (
    attendance_key BIGINT PRIMARY KEY,
    member_key INT NOT NULL,
    event_key INT NOT NULL,
    date_key INT NOT NULL,
    attendance_date DATE NOT NULL,
    attendance_time TIME NOT NULL,
    attendance_datetime TIMESTAMP NOT NULL,
    event_type VARCHAR(20) NOT NULL,
    sport VARCHAR(100),
    location VARCHAR(100) NOT NULL,
    FOREIGN KEY (member_key) REFERENCES dim_member(member_key),
    FOREIGN KEY (event_key) REFERENCES dim_event(event_key),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

-- ===== INDEXES FOR PERFORMANCE =====

CREATE INDEX idx_fact_ticket_sales_member ON fact_ticket_sales(member_key);
CREATE INDEX idx_fact_ticket_sales_event ON fact_ticket_sales(event_key);
CREATE INDEX idx_fact_ticket_sales_date ON fact_ticket_sales(date_key);
CREATE INDEX idx_fact_ticket_sales_sale_date ON fact_ticket_sales(sale_date);

CREATE INDEX idx_fact_dues_payments_member ON fact_dues_payments(member_key);
CREATE INDEX idx_fact_dues_payments_date ON fact_dues_payments(date_key);
CREATE INDEX idx_fact_dues_payments_payment_date ON fact_dues_payments(payment_date);

CREATE INDEX idx_fact_attendance_member ON fact_attendance(member_key);
CREATE INDEX idx_fact_attendance_event ON fact_attendance(event_key);
CREATE INDEX idx_fact_attendance_date ON fact_attendance(date_key);
CREATE INDEX idx_fact_attendance_attendance_date ON fact_attendance(attendance_date);

-- ===== DATE DIMENSION POPULATION =====
-- Generate date dimension for 2020-2030

INSERT INTO dim_date (date_key, full_date, year, quarter, month, month_name, day_of_year, day_of_month, day_of_week, day_name, is_weekend, fiscal_year, fiscal_quarter)
SELECT 
    EXTRACT(EPOCH FROM date_series)::INT as date_key,
    date_series as full_date,
    EXTRACT(YEAR FROM date_series) as year,
    EXTRACT(QUARTER FROM date_series) as quarter,
    EXTRACT(MONTH FROM date_series) as month,
    TO_CHAR(date_series, 'Month') as month_name,
    EXTRACT(DOY FROM date_series) as day_of_year,
    EXTRACT(DAY FROM date_series) as day_of_month,
    EXTRACT(DOW FROM date_series) as day_of_week,
    TO_CHAR(date_series, 'Day') as day_name,
    EXTRACT(DOW FROM date_series) IN (0, 6) as is_weekend,
    CASE 
        WHEN EXTRACT(MONTH FROM date_series) >= 4 
        THEN EXTRACT(YEAR FROM date_series)
        ELSE EXTRACT(YEAR FROM date_series) - 1
    END as fiscal_year,
    CASE 
        WHEN EXTRACT(MONTH FROM date_series) IN (4,5,6) THEN 1
        WHEN EXTRACT(MONTH FROM date_series) IN (7,8,9) THEN 2
        WHEN EXTRACT(MONTH FROM date_series) IN (10,11,12) THEN 3
        ELSE 4
    END as fiscal_quarter
FROM generate_series('2020-01-01'::date, '2030-12-31'::date, '1 day'::interval) as date_series;


