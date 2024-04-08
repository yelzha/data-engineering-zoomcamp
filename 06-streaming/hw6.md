## to do list:

```python
import json
import time 

from kafka import KafkaProducer

import pandas as pd

def json_serializer(data):
    return json.dumps(data).encode('utf-8')
    
def q4():
    t0 = time.time()

    topic_name = 'test-topic'

    for i in range(10):
        message = {'number': i}
        producer.send(topic_name, value=message)
        print(f"Sent: {message}")
        time.sleep(0.05)
    
    t1 = time.time()
    print(f't1 took {(t1 - t0):.2f} seconds')

    producer.flush()

    t2 = time.time()
    print(f't2 took {(t2 - t1):.2f} seconds')
    
    
def q5():
    t0 = time.time()
    
    topic_name = 'green-trips'
    df_green = pd.read_csv('green_tripdata_2019-10.csv.gz')
    for row in df_green.itertuples(index=False):
        row_dict = {col: getattr(row, col) for col in row._fields}
        # print(row_dict)
        producer.send(topic_name, value=row_dict)
        # break
    
    t1 = time.time()
    print(f't1 took {(t1 - t0):.2f} seconds')

server = 'localhost:9092'

producer = KafkaProducer(
    bootstrap_servers=[server],
    value_serializer=json_serializer
)

print('result:', producer.bootstrap_connected())

import os
import pyspark
from pyspark.sql import SparkSession

pyspark_version = pyspark.__version__
kafka_jar_package = f"org.apache.spark:spark-sql-kafka-0-10_2.12:{pyspark_version}"

os.environ['PYSPARK_SUBMIT_ARGS'] = f'--packages org.apache.spark:spark-streaming-kafka-0-10_2.12:3.2.0,{kafka_jar_package} pyspark-shell'

spark = SparkSession \
    .builder \
    .master("local[*]") \
    .appName("GreenTripsConsumer") \
    .config("spark.jars.packages", kafka_jar_package) \
    .getOrCreate()

green_stream = spark \
    .readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "green-trips") \
    .option("startingOffsets", "earliest") \
    .load()


from pyspark.sql import types

schema = types.StructType() \
    .add("lpep_pickup_datetime", types.StringType()) \
    .add("lpep_dropoff_datetime", types.StringType()) \
    .add("PULocationID", types.IntegerType()) \
    .add("DOLocationID", types.IntegerType()) \
    .add("passenger_count", types.DoubleType()) \
    .add("trip_distance", types.DoubleType()) \
    .add("tip_amount", types.DoubleType())

from pyspark.sql import functions as F

green_stream = green_stream \
  .select(F.from_json(F.col("value").cast('STRING'), schema).alias("data")) \
  .select("data.*")


from pyspark.sql import functions as F

popular_destinations = green_stream\
    .withColumn('timestamp', F.current_timestamp())\
    .withColumn('window', F.window(F.col("timestamp"), "5 minutes"))\
    .groupBy(F.col('window'), F.col('DOLocationID'))\
    .agg(F.count('lpep_pickup_datetime').alias('cnt'))\
    .orderBy(F.col('cnt').desc())\
    .limit(10)

query = popular_destinations \
    .writeStream \
    .queryName("green_view") \
    .format("memory") \
    .outputMode("complete") \
    .start()

# Use try-finally to ensure the streaming query is stopped properly when done
try:
    # Fetch and display the results periodically
    for _ in range(10):  # Adjust the range for longer observation
        spark.sql("SELECT * FROM green_view").show()
        time.sleep(10)  # Adjust the sleep time as needed
finally:
    query.stop()  # Stop the streaming query to release resources

```
