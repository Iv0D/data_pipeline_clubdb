-- Data transformation scripts to populate star schema from OLTP

-- ===== MEMBER DIMENSION POPULATION =====
INSERT INTO dim_member (
    member_key, member_id, first_name, last_name, full_name, document,
    registration_date, status, status_active, registration_year, registration_month,
    member_tenure_days, member_tenure_months
)
SELECT 
    idsocio as member_key,
    idsocio as member_id,
    nombre as first_name,
    apellido as last_name,
    CONCAT(nombre, ' ', apellido) as full_name,
    documento,
    fechaalta as registration_date,
    CASE WHEN estado = 1 THEN 'Active' ELSE 'Inactive' END as status,
    CASE WHEN estado = 1 THEN TRUE ELSE FALSE END as status_active,
    EXTRACT(YEAR FROM fechaalta) as registration_year,
    EXTRACT(MONTH FROM fechaalta) as registration_month,
    CURRENT_DATE - fechaalta as member_tenure_days,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, fechaalta)) * 12 + 
    EXTRACT(MONTH FROM AGE(CURRENT_DATE, fechaalta)) as member_tenure_months
FROM socio;

-- ===== EVENT DIMENSION POPULATION =====
-- Events
INSERT INTO dim_event (
    event_key, event_id, event_name, event_type, sport, location,
    event_date, event_time, event_datetime, event_year, event_month, event_quarter,
    is_weekend_event, venue_type
)
SELECT 
    idevento as event_key,
    idevento as event_id,
    nombre as event_name,
    'EVENT' as event_type,
    NULL as sport,
    lugar as location,
    fecha as event_date,
    hora as event_time,
    (fecha + hora) as event_datetime,
    EXTRACT(YEAR FROM fecha) as event_year,
    EXTRACT(MONTH FROM fecha) as event_month,
    EXTRACT(QUARTER FROM fecha) as event_quarter,
    EXTRACT(DOW FROM fecha) IN (0, 6) as is_weekend_event,
    CASE 
        WHEN lugar LIKE '%Estadio%' THEN 'Estadio'
        WHEN lugar LIKE '%Salón%' THEN 'Salón'
        WHEN lugar LIKE '%Auditorio%' THEN 'Auditorio'
        WHEN lugar LIKE '%Teatro%' THEN 'Teatro'
        WHEN lugar LIKE '%Galería%' THEN 'Galería'
        WHEN lugar LIKE '%Cine%' THEN 'Cine'
        WHEN lugar LIKE '%Patio%' THEN 'Patio'
        ELSE 'Other'
    END as venue_type
FROM evento;

-- Partidos (Sports matches)
INSERT INTO dim_event (
    event_key, event_id, event_name, event_type, sport, location,
    event_date, event_time, event_datetime, event_year, event_month, event_quarter,
    is_weekend_event, venue_type
)
SELECT 
    idpartido as event_key,
    idpartido as event_id,
    CONCAT(equipolocal, ' vs ', equipovisita) as event_name,
    'PARTIDO' as event_type,
    deporte as sport,
    lugar as location,
    fecha as event_date,
    hora as event_time,
    (fecha + hora) as event_datetime,
    EXTRACT(YEAR FROM fecha) as event_year,
    EXTRACT(MONTH FROM fecha) as event_month,
    EXTRACT(QUARTER FROM fecha) as event_quarter,
    EXTRACT(DOW FROM fecha) IN (0, 6) as is_weekend_event,
    'Estadio' as venue_type
FROM partido;

-- Actividades (Activities)
INSERT INTO dim_event (
    event_key, event_id, event_name, event_type, sport, location,
    event_date, event_time, event_datetime, event_year, event_month, event_quarter,
    is_weekend_event, venue_type
)
SELECT 
    idactividad as event_key,
    idactividad as event_id,
    nombre as event_name,
    'ACTIVIDAD' as event_type,
    NULL as sport,
    lugar as location,
    fecha as event_date,
    hora as event_time,
    (fecha + hora) as event_datetime,
    EXTRACT(YEAR FROM fecha) as event_year,
    EXTRACT(MONTH FROM fecha) as event_month,
    EXTRACT(QUARTER FROM fecha) as event_quarter,
    EXTRACT(DOW FROM fecha) IN (0, 6) as is_weekend_event,
    CASE 
        WHEN lugar LIKE '%Salón%' THEN 'Salón'
        WHEN lugar LIKE '%Gimnasio%' THEN 'Gimnasio'
        WHEN lugar LIKE '%Sala%' THEN 'Sala'
        WHEN lugar LIKE '%Parque%' THEN 'Parque'
        WHEN lugar LIKE '%Muro%' THEN 'Muro'
        WHEN lugar LIKE '%Circuito%' THEN 'Circuito'
        WHEN lugar LIKE '%Pista%' THEN 'Pista'
        ELSE 'Other'
    END as venue_type
FROM actividad;

-- ===== TICKET SALES FACT POPULATION =====
INSERT INTO fact_ticket_sales (
    ticket_sale_key, member_key, event_key, date_key, ticket_id, ticket_price,
    sale_date, sale_time, sale_datetime, event_type
)
SELECT 
    identrada as ticket_sale_key,
    idsocio as member_key,
    COALESCE(idevento, idpartido, idactividad) as event_key,
    EXTRACT(EPOCH FROM CURRENT_DATE)::INT as date_key, -- Using current date as sale date
    identrada as ticket_id,
    precio as ticket_price,
    CURRENT_DATE as sale_date,
    CURRENT_TIME as sale_time,
    CURRENT_TIMESTAMP as sale_datetime,
    CASE 
        WHEN idevento IS NOT NULL THEN 'EVENT'
        WHEN idpartido IS NOT NULL THEN 'PARTIDO'
        WHEN idactividad IS NOT NULL THEN 'ACTIVIDAD'
    END as event_type
FROM entrada;

-- ===== DUES PAYMENTS FACT POPULATION =====
INSERT INTO fact_dues_payments (
    dues_payment_key, member_key, date_key, payment_id, payment_amount,
    due_date, payment_date, payment_status, is_paid, is_overdue,
    days_overdue, payment_month, payment_year
)
SELECT 
    idcuota as dues_payment_key,
    idsocio as member_key,
    EXTRACT(EPOCH FROM fechavenc)::INT as date_key,
    idcuota as payment_id,
    precio as payment_amount,
    fechavenc as due_date,
    CASE 
        WHEN estado = 1 THEN fechavenc 
        ELSE NULL 
    END as payment_date,
    CASE 
        WHEN estado = 1 THEN 'Paid'
        WHEN fechavenc < CURRENT_DATE THEN 'Overdue'
        ELSE 'Pending'
    END as payment_status,
    CASE WHEN estado = 1 THEN TRUE ELSE FALSE END as is_paid,
    CASE 
        WHEN estado = 0 AND fechavenc < CURRENT_DATE THEN TRUE 
        ELSE FALSE 
    END as is_overdue,
    CASE 
        WHEN estado = 0 AND fechavenc < CURRENT_DATE 
        THEN CURRENT_DATE - fechavenc 
        ELSE 0 
    END as days_overdue,
    EXTRACT(MONTH FROM fechavenc) as payment_month,
    EXTRACT(YEAR FROM fechavenc) as payment_year
FROM cuota;

-- ===== ATTENDANCE FACT POPULATION =====
-- This is simulated data since we don't have actual attendance records
-- In a real scenario, this would come from check-in systems, ticket scanning, etc.
INSERT INTO fact_attendance (
    attendance_key, member_key, event_key, date_key, attendance_date,
    attendance_time, attendance_datetime, event_type, sport, location
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY e.identrada) as attendance_key,
    e.idsocio as member_key,
    COALESCE(e.idevento, e.idpartido, e.idactividad) as event_key,
    EXTRACT(EPOCH FROM ev.event_date)::INT as date_key,
    ev.event_date as attendance_date,
    ev.event_time as attendance_time,
    ev.event_datetime as attendance_datetime,
    ev.event_type,
    ev.sport,
    ev.location
FROM entrada e
JOIN dim_event ev ON COALESCE(e.idevento, e.idpartido, e.idactividad) = ev.event_id
WHERE RANDOM() < 0.8; -- Simulate 80% attendance rate


