-- Mart model for ticket sales fact
{{ config(materialized='table') }}

with entrada_data as (
    select * from {{ ref('stg_entrada') }}
),

member_dim as (
    select * from {{ ref('dim_member') }}
),

event_dim as (
    select * from {{ ref('dim_event') }}
),

ticket_sales_fact as (
    select
        ticket_id as ticket_sale_key,
        entrada_data.member_id as member_key,
        entrada_data.event_key as event_key,
        extract(epoch from current_date)::int as date_key,
        ticket_id,
        ticket_price,
        current_date as sale_date,
        current_time as sale_time,
        current_timestamp as sale_datetime,
        event_type
    from entrada_data
    left join member_dim on entrada_data.member_id = member_dim.member_id
    left join event_dim on entrada_data.event_key = event_dim.event_key
)

select * from ticket_sales_fact


