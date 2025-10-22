-- Staging model for raw entrada data
{{ config(materialized='view') }}

with source_data as (
    select * from {{ source('raw', 'entrada') }}
),

renamed as (
    select
        identrada as ticket_id,
        idsocio as member_id,
        precio as ticket_price,
        idevento as event_id,
        idpartido as partido_id,
        idactividad as actividad_id,
        case 
            when idevento is not null then 'EVENT'
            when idpartido is not null then 'PARTIDO'
            when idactividad is not null then 'ACTIVIDAD'
        end as event_type,
        coalesce(idevento, idpartido, idactividad) as event_key
    from source_data
)

select * from renamed


