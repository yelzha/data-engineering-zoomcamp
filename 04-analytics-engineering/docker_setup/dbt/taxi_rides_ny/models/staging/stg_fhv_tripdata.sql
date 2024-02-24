{{
    config(
        materialized='view'
    )
}}

with tripdata as
(
  select *
  from {{ source('staging', 'fhv_tripdata') }}
  where extract(year from pickup_datetime) = 2019
)
select
    --identifiers
    {{ dbt_utils.generate_surrogate_key(['dispatching_base_num', 'pickup_datetime', 'dropoff_datetime']) }} as tripid,
    dispatching_base_num,
    affiliated_base_number,
    {{ dbt.safe_cast("SR_Flag", api.Column.translate_type("integer")) }} as sr_flag,
    {{ dbt.safe_cast("pulocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("dolocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,

    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,
from tripdata

-- dbt build --select <model.sql> --vars '{'is_test_run': 'false'}'
-- dbt build --select stg_fhv_tripdata --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}