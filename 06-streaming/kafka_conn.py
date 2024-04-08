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

if __name__ == '__main__':
    server = 'localhost:9092'

    producer = KafkaProducer(
        bootstrap_servers=[server],
        value_serializer=json_serializer
    )

    print('result:', producer.bootstrap_connected())
    q5()