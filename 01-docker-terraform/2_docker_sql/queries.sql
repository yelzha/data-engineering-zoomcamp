--Q3
-- How many taxi trips were totally made on September 18th 2019?
SELECT
	COUNT(*)
FROM 
	public.green_taxi_trips
WHERE
	DATE(lpep_pickup_datetime) = '2019-09-18'
	AND DATE(lpep_dropoff_datetime) = '2019-09-18';
	
--Q4
-- Which was the pick up day with the largest trip distance Use the pick up time for your calculations.
SELECT
	DATE(lpep_pickup_datetime) as dt_pickup,
	MAX(trip_distance) as largest_trip
FROM 
	public.green_taxi_trips
GROUP BY
	1
ORDER BY
	largest_trip DESC
LIMIT 1;

--Q5
-- Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown
-- Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?
SELECT
	z."Borough",
	SUM(gtt.total_amount) as sum_total_amount
FROM 
	public.green_taxi_trips as gtt
LEFT JOIN public.zones as z
ON gtt."PULocationID" = z."LocationID"
WHERE
	DATE(lpep_pickup_datetime) = '2019-09-18'
GROUP BY
	z."Borough"
HAVING
	SUM(gtt.total_amount) > 50000
ORDER BY
	sum_total_amount DESC

--Q6
-- For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone 
-- that had the largest tip? We want the name of the zone, not the id.
SELECT
	zd."Zone" as zone_name,
	MAX(gtt.tip_amount) as max_tip_amount
FROM 
	public.green_taxi_trips as gtt
LEFT JOIN public.zones as zp
ON gtt."PULocationID" = zp."LocationID"
LEFT JOIN public.zones as zd
ON gtt."DOLocationID" = zd."LocationID"
WHERE
	EXTRACT(YEAR FROM lpep_pickup_datetime) = '2019'
	AND EXTRACT(MONTH FROM lpep_pickup_datetime) = '09'
	AND zp."Zone" = 'Astoria'
-- 	AND zd."Zone" = 'Astoria'
GROUP BY
	zd."Zone"
ORDER BY
	max_tip_amount DESC
LIMIT 5;