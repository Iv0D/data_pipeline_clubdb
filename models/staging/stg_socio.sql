-- Staging model for raw socio data
{{ config(materialized='view') }}

with source_data as (
    select * from {{ source('raw', 'socio') }}
),

renamed as (
    select
        idsocio as member_id,
        nombre as first_name,
        apellido as last_name,
        documento as document,
        fechaalta as registration_date,
        estado as status_code,
        case when estado = 1 then 'Active' else 'Inactive' end as status
    from source_data
)

select * from renamed


