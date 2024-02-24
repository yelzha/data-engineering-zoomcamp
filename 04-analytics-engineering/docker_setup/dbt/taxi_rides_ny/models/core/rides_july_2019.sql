{{
    config(
        materialized='table'
    )
}}

with trips_data as (
    select
        tripid,
        pickup_datetime,
        service_type
    from
        {{ ref('fact_trips') }}
), fhv_trips_data as (
    select
        tripid,
        pickup_datetime,
        'FHV' as service_type
    from
        {{ ref('fact_fhv_trips') }}
), all_trips AS (
    SELECT
        *
    FROM
        trips_data
    UNION ALL
    SELECT
        *
    FROM
        fhv_trips_data
)
select
    EXTRACT(date FROM pickup_datetime) AS pickup_date,
    service_type,
    COUNT(tripid) AS cnt
from all_trips
--WHERE
--    EXTRACT(month FROM pickup_datetime) = 6
--    AND EXTRACT(year FROM pickup_datetime) = 2019
GROUP BY
    pickup_date,
    service_type
ORDER BY
    pickup_date,
    service_type