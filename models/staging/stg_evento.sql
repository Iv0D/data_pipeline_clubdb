-- Staging model for raw evento data
{{ config(materialized='view') }}

with source_data as (
    select * from {{ source('raw', 'evento') }}
),

renamed as (
    select
        idevento as event_id,
        nombre as event_name,
        fecha as event_date,
        hora as event_time,
        lugar as location,
        'EVENT' as event_type,
        null as sport
    from source_data
)

select * from renamed


