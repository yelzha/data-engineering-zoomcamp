--External table
CREATE OR REPLACE EXTERNAL TABLE `de-zoomcamp-412720.zoomcamp_dataset.green_tripdata`
OPTIONS (
  format = 'parquet',
  uris = ['gs://de-zoomcamp-bucket-yelzha/green/green_tripdata_2022-*.parquet']
);

--BQ table 
CREATE OR REPLACE TABLE `de-zoomcamp-412720.zoomcamp_dataset.green_nonpartitioned_tripdata`
AS SELECT * FROM `de-zoomcamp-412720.zoomcamp_dataset.green_tripdata`;

--Q1
SELECT count(*) FROM `de-zoomcamp-412720.zoomcamp_dataset.green_tripdata`;


--Q2
--Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.
--Bytes processed: 0 MB
SELECT COUNT(DISTINCT PULocationID) FROM `de-zoomcamp-412720.zoomcamp_dataset.green_tripdata`;

--Creating materialized table
--Bytes processed: 6.41 MB
SELECT COUNT(DISTINCT PULocationID) FROM `de-zoomcamp-412720.zoomcamp_dataset.green_nonpartitioned_tripdata`;


--Q3
-- How many records have a fare_amount of 0?
SELECT COUNT(*) FROM `de-zoomcamp-412720.zoomcamp_dataset.green_tripdata` 
WHERE fare_amount = 0;


--Q4
--What is the best strategy to make an optimized table in Big Query 
--if your query will always order the results by PUlocationID and filter based on lpep_pickup_datetime? 
--(Create a new table with this strategy)
CREATE OR REPLACE TABLE `de-zoomcamp-412720.zoomcamp_dataset.green_partitioned_clustered_tripdata`
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PUlocationID AS (
  SELECT * FROM `de-zoomcamp-412720.zoomcamp_dataset.green_tripdata`
);


--Q5
--Write a query to retrieve the distinct PULocationID between lpep_pickup_datetime 06/01/2022 and 06/30/2022 (inclusive)
--Use the materialized table you created earlier in your from clause and note the estimated bytes. 
--Now change the table in the from clause to the partitioned table you created for question 4 and note the estimated bytes processed. 
--What are these values?
--Bytes processed: 12.82 MB
SELECT COUNT(DISTINCT PULocationID) FROM  `de-zoomcamp-412720.zoomcamp_dataset.green_nonpartitioned_tripdata`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';

--Bytes processed: 1.12 MB
SELECT COUNT(DISTINCT PULocationID) FROM  `de-zoomcamp-412720.zoomcamp_dataset.green_partitioned_clustered_tripdata`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';