-- Mart model for event dimension
{{ config(materialized='table') }}

with evento_data as (
    select * from {{ ref('stg_evento') }}
),

partido_data as (
    select * from {{ ref('stg_partido') }}
),

actividad_data as (
    select * from {{ ref('stg_actividad') }}
),

all_events as (
    select * from evento_data
    union all
    select * from partido_data
    union all
    select * from actividad_data
),

event_dimension as (
    select
        event_id as event_key,
        event_id,
        event_name,
        event_type,
        sport,
        location,
        event_date,
        event_time,
        (event_date + event_time) as event_datetime,
        extract(year from event_date) as event_year,
        extract(month from event_date) as event_month,
        extract(quarter from event_date) as event_quarter,
        extract(dow from event_date) in (0, 6) as is_weekend_event,
        case 
            when location like '%Estadio%' then 'Estadio'
            when location like '%Salón%' then 'Salón'
            when location like '%Auditorio%' then 'Auditorio'
            when location like '%Teatro%' then 'Teatro'
            when location like '%Galería%' then 'Galería'
            when location like '%Cine%' then 'Cine'
            when location like '%Patio%' then 'Patio'
            when location like '%Gimnasio%' then 'Gimnasio'
            when location like '%Sala%' then 'Sala'
            when location like '%Parque%' then 'Parque'
            when location like '%Muro%' then 'Muro'
            when location like '%Circuito%' then 'Circuito'
            when location like '%Pista%' then 'Pista'
            else 'Other'
        end as venue_type
    from all_events
)

select * from event_dimension


