-- Staging model for raw actividad data
{{ config(materialized='view') }}

with source_data as (
    select * from {{ source('raw', 'actividad') }}
),

renamed as (
    select
        idactividad as event_id,
        nombre as event_name,
        fecha as event_date,
        hora as event_time,
        lugar as location,
        'ACTIVIDAD' as event_type,
        null as sport
    from source_data
)

select * from renamed


