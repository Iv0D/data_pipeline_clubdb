-- Staging model for raw cuota data
{{ config(materialized='view') }}

with source_data as (
    select * from {{ source('raw', 'cuota') }}
),

renamed as (
    select
        idcuota as payment_id,
        idsocio as member_id,
        precio as payment_amount,
        fechavenc as due_date,
        estado as payment_status_code,
        case when estado = 1 then 'Paid' else 'Pending' end as payment_status,
        case when estado = 1 then true else false end as is_paid,
        case when estado = 0 and fechavenc < current_date then true else false end as is_overdue,
        case 
            when estado = 0 and fechavenc < current_date 
            then current_date - fechavenc 
            else 0 
        end as days_overdue
    from source_data
)

select * from renamed


