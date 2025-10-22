-- Mart model for dues payments fact
{{ config(materialized='table') }}

with cuota_data as (
    select * from {{ ref('stg_cuota') }}
),

member_dim as (
    select * from {{ ref('dim_member') }}
),

dues_payments_fact as (
    select
        payment_id as dues_payment_key,
        cuota_data.member_id as member_key,
        extract(epoch from due_date)::int as date_key,
        payment_id,
        payment_amount,
        due_date,
        case 
            when is_paid then due_date 
            else null 
        end as payment_date,
        payment_status,
        is_paid,
        is_overdue,
        days_overdue,
        extract(month from due_date) as payment_month,
        extract(year from due_date) as payment_year
    from cuota_data
    left join member_dim on cuota_data.member_id = member_dim.member_id
)

select * from dues_payments_fact


