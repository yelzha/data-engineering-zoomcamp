<p align="center">
  <picture>
    <source srcset="https://github.com/risingwavelabs/risingwave/blob/main/.github/RisingWave-logo-dark.svg" width="500px" media="(prefers-color-scheme: dark)">
    <img src="https://github.com/risingwavelabs/risingwave/blob/main/.github/RisingWave-logo-light.svg" width="500px">
  </picture>
</p>


</div>

<p align="center">
  <a
    href="https://docs.risingwave.com/"
    target="_blank"
  ><b>Documentation</b></a>&nbsp;&nbsp;&nbsp;📑&nbsp;&nbsp;&nbsp;
  <a
    href="https://tutorials.risingwave.com/"
    target="_blank"
  ><b>Hands-on Tutorials</b></a>&nbsp;&nbsp;&nbsp;🎯&nbsp;&nbsp;&nbsp;
  <a
    href="https://cloud.risingwave.com/"
    target="_blank"
  ><b>RisingWave Cloud</b></a>&nbsp;&nbsp;&nbsp;🚀&nbsp;&nbsp;&nbsp;
  <a
    href="https://risingwave.com/slack"
    target="_blank"
  >
    <b>Get Instant Help</b>
  </a>
</p>
<div align="center">
  <a
    href="https://risingwave.com/slack"
    target="_blank"
  >
    <img alt="Slack" src="https://badgen.net/badge/Slack/Join%20RisingWave/0abd59?icon=slack" />
  </a>
  <a
    href="https://twitter.com/risingwavelabs"
    target="_blank"
  >
    <img alt="X" src="https://img.shields.io/twitter/follow/risingwavelabs" />
  </a>
  <a
    href="https://www.youtube.com/@risingwave-labs"
    target="_blank"
  >
    <img alt="YouTube" src="https://img.shields.io/youtube/channel/views/UCsHwdyBRxBpmkA5RRd0YNEA" />
  </a>
</div>

## Checklist

### For Windows:

export PGHOST=localhost
export PGPORT=4566
export PGUSER=root
export PGDATABASE=dev


psql -h localhost -p 4566 -U root dev -f D:/ProjectFiles/risingwave-data-talks-workshop-2024-03-04/risingwave-sql/table/trip_data.sql

psql -h localhost -p 4566 -U root dev -f "D:\ProjectFiles\risingwave-data-talks-workshop-2024-03-04\risingwave-sql\table\trip_data.sql"

psql -h localhost -p 4566 -U root dev -f -c 'SHOW TABLES;'



```sql
select COUNT(*) from public.trip_data;


delete from public.trip_data;
   

--Q1,2 
CREATE MATERIALIZED VIEW avg_min_max AS
	select
		taxi_zone."zone" as zone_first,
		taxi_zone_1."zone" as zone_second,
		COUNT(*) as n_trips,
		AVG(tpep_dropoff_datetime - tpep_pickup_datetime) as avg_diff,
		MAX(tpep_dropoff_datetime - tpep_pickup_datetime) as max_diff,
		MIN(tpep_dropoff_datetime - tpep_pickup_datetime) as min_diff
	FROM 
		trip_data
	left JOIN 
		taxi_zone 
	ON 
		trip_data.PULocationID = taxi_zone.location_id
	left JOIN 
		taxi_zone as taxi_zone_1 
	ON 
		trip_data.DOLocationID = taxi_zone_1.location_id
	group by
		zone_first,
		zone_second
	order by
		avg_diff DESC

select * from avg_min_max
order by avg_diff desc;


--Q3
CREATE MATERIALIZED VIEW latest_pickup_time AS
    WITH t AS (
        SELECT MAX(tpep_pickup_datetime) AS latest_pickup_time
        FROM trip_data
    )
    SELECT 
    	taxi_zone.Zone as taxi_zone,
    	COUNT(*) as cnt
    FROM t,
            trip_data
    JOIN taxi_zone
        ON trip_data.PULocationID = taxi_zone.location_id
    WHERE trip_data.tpep_pickup_datetime BETWEEN t.latest_pickup_time - interval '17' hour and t.latest_pickup_time
   	group by 
   		taxi_zone
   	order by
   		cnt DESC
```





## Stream processing with RisingWave

In this hands-on workshop, we’ll learn how to process real-time streaming data using SQL in RisingWave. The system we’ll use is [RisingWave](https://github.com/risingwavelabs/risingwave), an open-source SQL database for processing and managing streaming data. You may not feel unfamiliar with RisingWave’s user experience, as it’s fully wire compatible with PostgreSQL.

![RisingWave](https://raw.githubusercontent.com/risingwavelabs/risingwave-docs/main/docs/images/new_archi_grey.png)



We’ll cover the following topics in this Workshop: 

- Why Stream Processing?
- Stateless computation (Filters, Projections)
- Stateful Computation (Aggregations, Joins)
- Data Ingestion and Delivery

RisingWave in 10 Minutes:
https://tutorials.risingwave.com/docs/intro

Workshop video:

<a href="https://youtube.com/live/L2BHFnZ6XjE">
  <img src="https://markdown-videos-api.jorgenkh.no/youtube/L2BHFnZ6XjE" />
</a>

[Project Repository](https://github.com/risingwavelabs/risingwave-data-talks-workshop-2024-03-04)

## Homework

**Please setup the environment in [Getting Started](https://github.com/risingwavelabs/risingwave-data-talks-workshop-2024-03-04?tab=readme-ov-file#getting-started) and for the [Homework](https://github.com/risingwavelabs/risingwave-data-talks-workshop-2024-03-04/blob/main/homework.md#setting-up) first.**


## Question 0

_This question is just a warm-up to introduce dynamic filter, please attempt it before viewing its solution._

What are the dropoff taxi zones at the latest dropoff times?

For this part, we will use the [dynamic filter pattern](https://docs.risingwave.com/docs/current/sql-pattern-dynamic-filters/).

<details>
<summary>Solution</summary>

```sql
CREATE MATERIALIZED VIEW latest_dropoff_time AS
    WITH t AS (
        SELECT MAX(tpep_dropoff_datetime) AS latest_dropoff_time
        FROM trip_data
    )
    SELECT taxi_zone.Zone as taxi_zone, latest_dropoff_time
    FROM t,
            trip_data
    JOIN taxi_zone
        ON trip_data.DOLocationID = taxi_zone.location_id
    WHERE trip_data.tpep_dropoff_datetime = t.latest_dropoff_time;

--    taxi_zone    | latest_dropoff_time
-- ----------------+---------------------
--  Midtown Center | 2022-01-03 17:24:54
-- (1 row)
```

</details>

### Question 1

Create a materialized view to compute the average, min and max trip time between each taxi zone.

From this MV, find the pair of taxi zones with the highest average trip time.
You may need to use the [dynamic filter pattern](https://docs.risingwave.com/docs/current/sql-pattern-dynamic-filters/) for this.

Bonus (no marks): Create an MV which can identify anomalies in the data. For example, if the average trip time between two zones is 1 minute,
but the max trip time is 10 minutes and 20 minutes respectively.

Options:
1. Yorkville East, Steinway
2. Murray Hill, Midwood
3. East Flatbush/Farragut, East Harlem North
4. Midtown Center, University Heights/Morris Heights

### Question 2

Recreate the MV(s) in question 1, to also find the number of trips for the pair of taxi zones with the highest average trip time.

Options:
1. 5
2. 3
3. 10
4. 1

### Question 3

From the latest pickup time to 17 hours before, what are the top 3 busiest zones in terms of number of pickups?
For example if the latest pickup time is 2020-01-01 12:00:00,
then the query should return the top 3 busiest zones from 2020-01-01 11:00:00 to 2020-01-01 12:00:00.

HINT: You can use [dynamic filter pattern](https://docs.risingwave.com/docs/current/sql-pattern-dynamic-filters/)
to create a filter condition based on the latest pickup time.

NOTE: For this question `17 hours` was picked to ensure we have enough data to work with.

Options:
1. Clinton East, Upper East Side North, Penn Station
2. LaGuardia Airport, Lincoln Square East, JFK Airport
3. Midtown Center, Upper East Side South, Upper East Side North
4. LaGuardia Airport, Midtown Center, Upper East Side North


## Submitting the solutions

- Form for submitting: https://courses.datatalks.club/de-zoomcamp-2024/homework/workshop2
- Deadline: 11 March (Monday), 23:00 CET 

## Rewards 🥳

Everyone who completes the homework will get a pen and a sticker, and 5 lucky winners will receive a Tshirt and other secret surprises!
We encourage you to share your achievements with this workshop on your socials and look forward to your submissions 😁

- Follow us on **LinkedIn**: https://www.linkedin.com/company/risingwave
- Follow us on **GitHub**: https://github.com/risingwavelabs/risingwave
- Join us on **Slack**: https://risingwave-labs.com/slack

See you around!


## Solution
