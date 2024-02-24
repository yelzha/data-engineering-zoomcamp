CREATE TABLE  `de-zoomcamp-412720.dbt.green_tripdata` as
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2019`; 
insert into  `de-zoomcamp-412720.dbt.green_tripdata`
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2020` ;


CREATE TABLE  `de-zoomcamp-412720.dbt.yellow_tripdata` as
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2019`;
insert into  `de-zoomcamp-412720.dbt.yellow_tripdata`
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`; 


  -- Fixes yellow table schema
ALTER TABLE `de-zoomcamp-412720.dbt.yellow_tripdata`
  RENAME COLUMN vendor_id TO VendorID;
ALTER TABLE `de-zoomcamp-412720.dbt.yellow_tripdata`
  RENAME COLUMN pickup_datetime TO tpep_pickup_datetime;
ALTER TABLE `de-zoomcamp-412720.dbt.yellow_tripdata`
  RENAME COLUMN dropoff_datetime TO tpep_dropoff_datetime;
ALTER TABLE `de-zoomcamp-412720.dbt.yellow_tripdata`
  RENAME COLUMN rate_code TO RatecodeID;
ALTER TABLE `de-zoomcamp-412720.dbt.yellow_tripdata`
  RENAME COLUMN imp_surcharge TO improvement_surcharge;
ALTER TABLE `de-zoomcamp-412720.dbt.yellow_tripdata`
  RENAME COLUMN pickup_location_id TO PULocationID;
ALTER TABLE `de-zoomcamp-412720.dbt.yellow_tripdata`
  RENAME COLUMN dropoff_location_id TO DOLocationID;

  -- Fixes green table schema
ALTER TABLE `de-zoomcamp-412720.dbt.green_tripdata`
  RENAME COLUMN vendor_id TO VendorID;
ALTER TABLE `de-zoomcamp-412720.dbt.green_tripdata`
  RENAME COLUMN pickup_datetime TO lpep_pickup_datetime;
ALTER TABLE `de-zoomcamp-412720.dbt.green_tripdata`
  RENAME COLUMN dropoff_datetime TO lpep_dropoff_datetime;
ALTER TABLE `de-zoomcamp-412720.dbt.green_tripdata`
  RENAME COLUMN rate_code TO RatecodeID;
ALTER TABLE `de-zoomcamp-412720.dbt.green_tripdata`
  RENAME COLUMN imp_surcharge TO improvement_surcharge;
ALTER TABLE `de-zoomcamp-412720.dbt.green_tripdata`
  RENAME COLUMN pickup_location_id TO PULocationID;
ALTER TABLE `de-zoomcamp-412720.dbt.green_tripdata`
  RENAME COLUMN dropoff_location_id TO DOLocationID;




--FHV
CREATE OR REPLACE EXTERNAL TABLE `de-zoomcamp-412720.dbt.fhv_tripdata_external` ( 
  dispatching_base_num STRING, 
  pickup_datetime TIMESTAMP,  
  dropoff_datetime TIMESTAMP,  
  PULocationID STRING,  
  DOLocationID STRING,  
  SR_Flag STRING,  
  Affiliated_base_number STRING
  )
OPTIONS (
  format = 'parquet',
  uris = [
    'gs://de-zoomcamp-bucket-yelzha/fhv/fhv_tripdata_2019-*.parquet'
  ]
);

CREATE OR REPLACE TABLE `de-zoomcamp-412720.dbt.fhv_tripdata` AS 
SELECT * FROM `de-zoomcamp-412720.dbt.fhv_tripdata_external`;

SELECT DISTINCT
  SR_Flag 
FROM `de-zoomcamp-412720.dbt.fhv_tripdata_external`
WHERE
  SR_Flag IS NOT NULL
LIMIT 50;

SELECT COUNT(*) FROM `de-zoomcamp-412720.dbt.fact_fhv_trips`;

SELECT
  EXTRACT(date FROM pickup_datetime) as d,
  service_type,
  COUNT(*) AS cnt
FROM
  `de-zoomcamp-412720.dbt.rides_july_2019`
WHERE
  EXTRACT(year FROM pickup_datetime) = 2019
  AND EXTRACT(month FROM pickup_datetime) = 6
GROUP BY
  d,
  service_type;



