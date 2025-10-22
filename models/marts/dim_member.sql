-- Mart model for member dimension
{{ config(materialized='table') }}

with socio_data as (
    select * from {{ ref('stg_socio') }}
),

member_dimension as (
    select
        member_id as member_key,
        member_id,
        first_name,
        last_name,
        concat(first_name, ' ', last_name) as full_name,
        document,
        registration_date,
        status,
        case when status = 'Active' then true else false end as status_active,
        extract(year from registration_date) as registration_year,
        extract(month from registration_date) as registration_month,
        current_date - registration_date as member_tenure_days,
        extract(year from age(current_date, registration_date)) * 12 + 
        extract(month from age(current_date, registration_date)) as member_tenure_months
    from socio_data
)

select * from member_dimension


