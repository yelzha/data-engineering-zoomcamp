## Week 3 Homework

<b><u>Important Note:</b></u> <p> For this homework we will be using the 2022 Green Taxi Trip Record Parquet Files from the New York
City Taxi Data found here: </br> https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page </br>
If you are using orchestration such as Mage, Airflow or Prefect do not load the data into Big Query using the orchestrator.</br> 
Stop with loading the files into a bucket. </br></br>
<u>NOTE:</u> You will need to use the PARQUET option files when creating an External Table</br>

```python
import io
import os
import requests
import pandas as pd
from google.cloud import storage

"""
Pre-reqs: 
1. `pip install pandas pyarrow google-cloud-storage`
2. Set GOOGLE_APPLICATION_CREDENTIALS to your project/service-account key
3. Set GCP_GCS_BUCKET as your bucket or change default value of BUCKET
"""

# services = ['fhv','green','yellow']
init_url = 'https://d37ci6vzurychx.cloudfront.net/trip-data'
# switch out the bucketname
BUCKET = os.environ.get("GCP_GCS_BUCKET", "de-zoomcamp-bucket-yelzha")


def upload_to_gcs(bucket, object_name, local_file):
    """
    Ref: https://cloud.google.com/storage/docs/uploading-objects#storage-upload-object-python
    """
    # # WORKAROUND to prevent timeout for files > 6 MB on 800 kbps upload speed.
    # # (Ref: https://github.com/googleapis/python-storage/issues/74)
    # storage.blob._MAX_MULTIPART_SIZE = 5 * 1024 * 1024  # 5 MB
    # storage.blob._DEFAULT_CHUNKSIZE = 5 * 1024 * 1024  # 5 MB

    client = storage.Client()
    bucket = client.bucket(bucket)
    blob = bucket.blob(object_name)
    blob.upload_from_filename(local_file)


def web_to_gcs(year, service):
    for i in range(12):
        
        # sets the month part of the file_name string
        month = '0'+str(i+1)
        month = month[-2:]

        # csv file_name
        # green_tripdata_2022-02.parquet
        file_name = f"{service}_tripdata_{year}-{month}.parquet"

        # download it using requests via a pandas df
        request_url = f"{init_url}/{file_name}"
        r = requests.get(request_url)
        open(file_name, 'wb').write(r.content)
        print(f"Local: {file_name}")

        # read it back into a parquet file
        df = pd.read_parquet(file_name)
        print(f"Parquet: {file_name}")

        # upload it to gcs 
        upload_to_gcs(BUCKET, f"{service}/{file_name}", file_name)
        print(f"GCS: {service}/{file_name}")


if __name__ == '__main__':
    web_to_gcs('2022', 'green')
```

<b>SETUP:</b></br>
Create an external table using the Green Taxi Trip Records Data for 2022. </br>
Create a table in BQ using the Green Taxi Trip Records for 2022 (do not partition or cluster this table). </br>
</p>
```sql
CREATE OR REPLACE EXTERNAL TABLE `de-zoomcamp-412720.zoomcamp_dataset.green_tripdata`
OPTIONS (
  format = 'parquet',
  uris = ['gs://de-zoomcamp-bucket-yelzha/green/green_tripdata_2022-*.parquet']
);

CREATE OR REPLACE TABLE `de-zoomcamp-412720.zoomcamp_dataset.green_nonpartitioned_tripdata`
AS SELECT * FROM `de-zoomcamp-412720.zoomcamp_dataset.green_tripdata`;
```

## Question 1:
Question 1: What is count of records for the 2022 Green Taxi Data??
- 65,623,481
- 840,402
- 1,936,423
- 253,647
```sql
SELECT count(*) FROM `de-zoomcamp-412720.zoomcamp_dataset.green_tripdata`;
```


## Question 2:
Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.</br> 
What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?

- 0 MB for the External Table and 6.41MB for the Materialized Table
- 18.82 MB for the External Table and 47.60 MB for the Materialized Table
- 0 MB for the External Table and 0MB for the Materialized Table
- 2.14 MB for the External Table and 0MB for the Materialized Table
```sql
SELECT COUNT(DISTINCT PULocationID) FROM `de-zoomcamp-412720.zoomcamp_dataset.green_tripdata`;

SELECT COUNT(DISTINCT PULocationID) FROM `de-zoomcamp-412720.zoomcamp_dataset.green_nonpartitioned_tripdata`;
```

## Question 3:
How many records have a fare_amount of 0?
- 12,488
- 128,219
- 112
- 1,622

```sql
--Q3
SELECT COUNT(*) FROM `de-zoomcamp-412720.zoomcamp_dataset.green_tripdata` 
WHERE fare_amount = 0;
```

## Question 4:
What is the best strategy to make an optimized table in Big Query if your query will always order the results by PUlocationID and filter based on lpep_pickup_datetime? (Create a new table with this strategy)
- Cluster on lpep_pickup_datetime Partition by PUlocationID
- Partition by lpep_pickup_datetime  Cluster on PUlocationID
- Partition by lpep_pickup_datetime and Partition by PUlocationID
- Cluster on by lpep_pickup_datetime and Cluster on PUlocationID

```sql
--Q4
CREATE OR REPLACE TABLE `de-zoomcamp-412720.zoomcamp_dataset.green_partitioned_clustered_tripdata`
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PUlocationID AS (
  SELECT * FROM `de-zoomcamp-412720.zoomcamp_dataset.green_tripdata`
);
```

## Question 5:
Write a query to retrieve the distinct PULocationID between lpep_pickup_datetime
06/01/2022 and 06/30/2022 (inclusive)</br>

Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 4 and note the estimated bytes processed. What are these values? </br>

Choose the answer which most closely matches.</br> 

- 22.82 MB for non-partitioned table and 647.87 MB for the partitioned table
- 12.82 MB for non-partitioned table and 1.12 MB for the partitioned table
- 5.63 MB for non-partitioned table and 0 MB for the partitioned table
- 10.31 MB for non-partitioned table and 10.31 MB for the partitioned table
```sql
SELECT COUNT(DISTINCT PULocationID) FROM  `de-zoomcamp-412720.zoomcamp_dataset.green_nonpartitioned_tripdata`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';

SELECT COUNT(DISTINCT PULocationID) FROM  `de-zoomcamp-412720.zoomcamp_dataset.green_partitioned_clustered_tripdata`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';
```

## Question 6: 
Where is the data stored in the External Table you created?

- Big Query
- GCP Bucket
- Big Table
- Container Registry


## Question 7:
It is best practice in Big Query to always cluster your data:
- True
- False


## (Bonus: Not worth points) Question 8:
No Points: Write a `SELECT count(*)` query FROM the materialized table you created. How many bytes does it estimate will be read? Why?

```sql
SELECT count(*) FROM  `de-zoomcamp-412720.zoomcamp_dataset.green_partitioned_clustered_tripdata`;
```
 
## Submitting the solutions

* Form for submitting: https://courses.datatalks.club/de-zoomcamp-2024/homework/hw3


