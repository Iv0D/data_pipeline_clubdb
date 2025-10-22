-- Staging model for raw partido data
{{ config(materialized='view') }}

with source_data as (
    select * from {{ source('raw', 'partido') }}
),

renamed as (
    select
        idpartido as event_id,
        concat(equipolocal, ' vs ', equipovisita) as event_name,
        fecha as event_date,
        hora as event_time,
        lugar as location,
        'PARTIDO' as event_type,
        deporte as sport
    from source_data
)

select * from renamed


