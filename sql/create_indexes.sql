-- Database Indexes for Club Analytics Pipeline
-- This script creates indexes on join columns and date columns for optimal query performance

-- Create analytics schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS analytics;

-- ==============================================
-- INDEXES FOR DIMENSION TABLES
-- ==============================================

-- Member dimension indexes
CREATE INDEX IF NOT EXISTS idx_dim_member_member_id 
ON analytics.dim_member (member_id);

CREATE INDEX IF NOT EXISTS idx_dim_member_status_active 
ON analytics.dim_member (status_active);

CREATE INDEX IF NOT EXISTS idx_dim_member_registration_date 
ON analytics.dim_member (registration_date);

CREATE INDEX IF NOT EXISTS idx_dim_member_status 
ON analytics.dim_member (status);

-- Event dimension indexes
CREATE INDEX IF NOT EXISTS idx_dim_event_event_id 
ON analytics.dim_event (event_id);

CREATE INDEX IF NOT EXISTS idx_dim_event_event_date 
ON analytics.dim_event (event_date);

CREATE INDEX IF NOT EXISTS idx_dim_event_event_type 
ON analytics.dim_event (event_type);

CREATE INDEX IF NOT EXISTS idx_dim_event_sport 
ON analytics.dim_event (sport);

CREATE INDEX IF NOT EXISTS idx_dim_event_location 
ON analytics.dim_event (location);

-- Date dimension indexes
CREATE INDEX IF NOT EXISTS idx_dim_date_full_date 
ON analytics.dim_date (full_date);

CREATE INDEX IF NOT EXISTS idx_dim_date_year 
ON analytics.dim_date (year);

CREATE INDEX IF NOT EXISTS idx_dim_date_month 
ON analytics.dim_date (month);

CREATE INDEX IF NOT EXISTS idx_dim_date_quarter 
ON analytics.dim_date (quarter);

CREATE INDEX IF NOT EXISTS idx_dim_date_weekday 
ON analytics.dim_date (weekday);

-- ==============================================
-- INDEXES FOR FACT TABLES
-- ==============================================

-- Ticket sales fact table indexes
CREATE INDEX IF NOT EXISTS idx_fact_ticket_sales_member_key 
ON analytics.fact_ticket_sales (member_key);

CREATE INDEX IF NOT EXISTS idx_fact_ticket_sales_event_key 
ON analytics.fact_ticket_sales (event_key);

CREATE INDEX IF NOT EXISTS idx_fact_ticket_sales_date_key 
ON analytics.fact_ticket_sales (date_key);

CREATE INDEX IF NOT EXISTS idx_fact_ticket_sales_sale_date 
ON analytics.fact_ticket_sales (sale_date);

CREATE INDEX IF NOT EXISTS idx_fact_ticket_sales_ticket_price 
ON analytics.fact_ticket_sales (ticket_price);

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_fact_ticket_sales_member_date 
ON analytics.fact_ticket_sales (member_key, date_key);

CREATE INDEX IF NOT EXISTS idx_fact_ticket_sales_event_date 
ON analytics.fact_ticket_sales (event_key, date_key);

CREATE INDEX IF NOT EXISTS idx_fact_ticket_sales_date_price 
ON analytics.fact_ticket_sales (sale_date, ticket_price);

-- Dues payments fact table indexes
CREATE INDEX IF NOT EXISTS idx_fact_dues_payments_member_key 
ON analytics.fact_dues_payments (member_key);

CREATE INDEX IF NOT EXISTS idx_fact_dues_payments_date_key 
ON analytics.fact_dues_payments (date_key);

CREATE INDEX IF NOT EXISTS idx_fact_dues_payments_payment_date 
ON analytics.fact_dues_payments (payment_date);

CREATE INDEX IF NOT EXISTS idx_fact_dues_payments_payment_amount 
ON analytics.fact_dues_payments (payment_amount);

CREATE INDEX IF NOT EXISTS idx_fact_dues_payments_is_paid 
ON analytics.fact_dues_payments (is_paid);

CREATE INDEX IF NOT EXISTS idx_fact_dues_payments_payment_status 
ON analytics.fact_dues_payments (payment_status);

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_fact_dues_payments_member_date 
ON analytics.fact_dues_payments (member_key, date_key);

CREATE INDEX IF NOT EXISTS idx_fact_dues_payments_date_paid 
ON analytics.fact_dues_payments (payment_date, is_paid);

CREATE INDEX IF NOT EXISTS idx_fact_dues_payments_member_paid 
ON analytics.fact_dues_payments (member_key, is_paid);

-- ==============================================
-- INDEXES FOR RAW TABLES
-- ==============================================

-- Raw socio (member) table indexes
CREATE INDEX IF NOT EXISTS idx_raw_socio_idsocio 
ON raw.socio (idsocio);

CREATE INDEX IF NOT EXISTS idx_raw_socio_fechaalta 
ON raw.socio (fechaalta);

CREATE INDEX IF NOT EXISTS idx_raw_socio_estado 
ON raw.socio (estado);

-- Raw entrada (ticket) table indexes
CREATE INDEX IF NOT EXISTS idx_raw_entrada_identrada 
ON raw.entrada (identrada);

CREATE INDEX IF NOT EXISTS idx_raw_entrada_idsocio 
ON raw.entrada (idsocio);

CREATE INDEX IF NOT EXISTS idx_raw_entrada_idevento 
ON raw.entrada (idevento);

CREATE INDEX IF NOT EXISTS idx_raw_entrada_idpartido 
ON raw.entrada (idpartido);

CREATE INDEX IF NOT EXISTS idx_raw_entrada_idactividad 
ON raw.entrada (idactividad);

-- Raw cuota (dues) table indexes
CREATE INDEX IF NOT EXISTS idx_raw_cuota_idcuota 
ON raw.cuota (idcuota);

CREATE INDEX IF NOT EXISTS idx_raw_cuota_idsocio 
ON raw.cuota (idsocio);

CREATE INDEX IF NOT EXISTS idx_raw_cuota_fechavenc 
ON raw.cuota (fechavenc);

CREATE INDEX IF NOT EXISTS idx_raw_cuota_estado 
ON raw.cuota (estado);

-- Raw evento table indexes
CREATE INDEX IF NOT EXISTS idx_raw_evento_idevento 
ON raw.evento (idevento);

CREATE INDEX IF NOT EXISTS idx_raw_evento_fecha 
ON raw.evento (fecha);

-- Raw partido table indexes
CREATE INDEX IF NOT EXISTS idx_raw_partido_idpartido 
ON raw.partido (idpartido);

CREATE INDEX IF NOT EXISTS idx_raw_partido_idequipo 
ON raw.partido (idequipo);

CREATE INDEX IF NOT EXISTS idx_raw_partido_fecha 
ON raw.partido (fecha);

CREATE INDEX IF NOT EXISTS idx_raw_partido_deporte 
ON raw.partido (deporte);

-- Raw actividad table indexes
CREATE INDEX IF NOT EXISTS idx_raw_actividad_idactividad 
ON raw.actividad (idactividad);

CREATE INDEX IF NOT EXISTS idx_raw_actividad_fecha 
ON raw.actividad (fecha);

-- ==============================================
-- PARTIAL INDEXES FOR PERFORMANCE
-- ==============================================

-- Partial indexes for active records only
CREATE INDEX IF NOT EXISTS idx_dim_member_active_only 
ON analytics.dim_member (member_id) 
WHERE status_active = true;

CREATE INDEX IF NOT EXISTS idx_fact_dues_payments_paid_only 
ON analytics.fact_dues_payments (member_key, payment_date) 
WHERE is_paid = true;

-- Partial indexes for recent data
CREATE INDEX IF NOT EXISTS idx_fact_ticket_sales_recent 
ON analytics.fact_ticket_sales (sale_date, ticket_price) 
WHERE sale_date >= CURRENT_DATE - INTERVAL '1 year';

CREATE INDEX IF NOT EXISTS idx_fact_dues_payments_recent 
ON analytics.fact_dues_payments (payment_date, payment_amount) 
WHERE payment_date >= CURRENT_DATE - INTERVAL '1 year';

-- ==============================================
-- STATISTICS AND MAINTENANCE
-- ==============================================

-- Update table statistics for better query planning
ANALYZE analytics.dim_member;
ANALYZE analytics.dim_event;
ANALYZE analytics.dim_date;
ANALYZE analytics.fact_ticket_sales;
ANALYZE analytics.fact_dues_payments;

-- Update raw table statistics
ANALYZE raw.socio;
ANALYZE raw.entrada;
ANALYZE raw.cuota;
ANALYZE raw.evento;
ANALYZE raw.partido;
ANALYZE raw.actividad;

-- ==============================================
-- INDEX MONITORING QUERIES
-- ==============================================

-- Query to check index usage (run periodically)
/*
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE schemaname IN ('analytics', 'raw')
ORDER BY idx_scan DESC;
*/

-- Query to check index sizes
/*
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes 
WHERE schemaname IN ('analytics', 'raw')
ORDER BY pg_relation_size(indexrelid) DESC;
*/

-- ==============================================
-- COMMENTS FOR DOCUMENTATION
-- ==============================================

COMMENT ON INDEX idx_dim_member_member_id IS 'Primary lookup index for member dimension';
COMMENT ON INDEX idx_fact_ticket_sales_member_key IS 'Foreign key index for member joins';
COMMENT ON INDEX idx_fact_ticket_sales_event_key IS 'Foreign key index for event joins';
COMMENT ON INDEX idx_fact_ticket_sales_date_key IS 'Foreign key index for date joins';
COMMENT ON INDEX idx_fact_ticket_sales_sale_date IS 'Date range query optimization';
COMMENT ON INDEX idx_fact_dues_payments_member_key IS 'Foreign key index for member joins';
COMMENT ON INDEX idx_fact_dues_payments_payment_date IS 'Date range query optimization';
COMMENT ON INDEX idx_fact_dues_payments_is_paid IS 'Filter optimization for paid/unpaid queries';
