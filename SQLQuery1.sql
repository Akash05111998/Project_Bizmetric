use gold;

select * from [silver_db].[delivery_data]


select * from[silver_db].[driver_data]

select * from[silver_db].[route_data]
select * from[silver_db].[vechile_data]

select * from[silver_db].[Silver_table]


SELECT 
    p.start_location + ' to ' + p.end_location AS route_name,
    COUNT(d.delivery_id) AS total_deliveries
FROM silver_db.delivery_data d
JOIN silver_db.route_data p ON d.route_id = p.route_id
GROUP BY p.start_location + ' to ' + p.end_location
ORDER BY total_deliveries DESC;

CREATE TABLE gold.total_deliveries_per_route (
    route_name NVARCHAR(255),
    total_deliveries INT
);

CREATE SCHEMA gold;

INSERT INTO gold.total_deliveries_per_route (route_name, total_deliveries)
SELECT 
    p.start_location + ' to ' + p.end_location AS route_name,
    COUNT(d.delivery_id) AS total_deliveries
FROM silver_db.delivery_data d
JOIN silver_db.route_data p ON d.route_id = p.route_id
GROUP BY p.start_location + ' to ' + p.end_location
ORDER BY total_deliveries DESC;



CREATE TABLE gold.avg_delivery_time_per_route (
    route_name NVARCHAR(255),
    avg_delivery_time FLOAT
);

INSERT INTO gold.avg_delivery_time_per_route (route_name, avg_delivery_time)
SELECT 
    ISNULL(r.start_location, '') + ' to ' + ISNULL(r.end_location, '') AS route_name,
    ROUND(AVG(CAST(d.delivery_time AS FLOAT)), 2) AS avg_delivery_time
FROM silver_db.delivery_data d
JOIN silver_db.route_data r ON d.route_id = r.route_id
GROUP BY ISNULL(r.start_location, '') + ' to ' + ISNULL(r.end_location, '')
ORDER BY avg_delivery_time;


CREATE TABLE gold.avg_fuel_consumption_per_route (
    route_name NVARCHAR(255),
    avg_fuel_consumption FLOAT
);

INSERT INTO gold.avg_fuel_consumption_per_route (route_name, avg_fuel_consumption)
SELECT 
    ISNULL(r.start_location, '') + ' to ' + ISNULL(r.end_location, '') AS route_name,
    ROUND(AVG(CAST(v.fuel_efficiency AS FLOAT)), 2) AS avg_fuel_consumption
FROM silver_db.delivery_data d
JOIN silver_db.route_data r ON d.route_id = r.route_id
JOIN silver_db.vechile_data v ON d.vehicle_id = v.vehicle_id
WHERE v.fuel_efficiency IS NOT NULL
GROUP BY ISNULL(r.start_location, '') + ' to ' + ISNULL(r.end_location, '')
ORDER BY avg_fuel_consumption;


INSERT INTO gold.avg_fuel_consumption_per_route (route_name, avg_fuel_consumption)
SELECT 
    ISNULL(r.start_location, '') + ' to ' + ISNULL(r.end_location, '') AS route_name,
    ROUND(AVG(CAST(d.distance_covered AS FLOAT) / NULLIF(CAST(v.fuel_efficiency AS FLOAT), 0)), 2) AS avg_fuel_consumption
FROM silver_db.delivery_data d
JOIN silver_db.route_data r ON d.route_id = r.route_id
JOIN silver_db.vechile_data v ON d.vehicle_id = v.vehicle_id
WHERE v.fuel_efficiency IS NOT NULL AND d.distance_covered IS NOT NULL
GROUP BY ISNULL(r.start_location, '') + ' to ' + ISNULL(r.end_location, '')
ORDER BY avg_fuel_consumption;


CREATE TABLE [gold].[driver_summary] (
    vehicle_type VARCHAR(50),
    total_vehicles INT,
    avg_fuel_efficiency DECIMAL(10,2),
    min_fuel_efficiency DECIMAL(10,2),
    max_fuel_efficiency DECIMAL(10,2),
    avg_capacity DECIMAL(10,2),
    min_capacity INT,
    max_capacity INT
);

INSERT INTO [gold].[driver_summary] (
    vehicle_type,
    total_vehicles,
    avg_fuel_efficiency,
    min_fuel_efficiency,
    max_fuel_efficiency,
    avg_capacity,
    min_capacity,
    max_capacity
)
SELECT
    vehicle_type,
    COUNT(*) AS total_vehicles,
    ROUND(AVG(CAST(fuel_efficiency AS FLOAT)), 2) AS avg_fuel_efficiency,
    MIN(CAST(fuel_efficiency AS FLOAT)) AS min_fuel_efficiency,
    MAX(CAST(fuel_efficiency AS FLOAT)) AS max_fuel_efficiency,
    ROUND(AVG(CAST(capacity AS FLOAT)), 2) AS avg_capacity,
    MIN(CAST(capacity AS INT)) AS min_capacity,
    MAX(CAST(capacity AS INT)) AS max_capacity
FROM
    [silver_db].[driver_data]
WHERE
    vehicle_type IS NOT NULL
    AND ISNUMERIC(fuel_efficiency) = 1
    AND ISNUMERIC(capacity) = 1
GROUP BY
    vehicle_type;


	INSERT INTO gold.avg_fuel_consumption_per_route (route_name, avg_fuel_consumption)
SELECT 
    ISNULL(r.start_location, '') + ' to ' + ISNULL(r.end_location, '') AS route_name,
    ROUND(AVG(CAST(d.distance_covered AS FLOAT) / NULLIF(CAST(v.fuel_efficiency AS FLOAT), 0)), 2) AS avg_fuel_consumption
FROM silver_db.delivery_data d
JOIN silver_db.route_data r ON d.route_id = r.route_id
JOIN silver_db.driver_data v ON d.vehicle_id = v.vehicle_id
WHERE v.fuel_efficiency IS NOT NULL AND d.distance_covered IS NOT NULL
GROUP BY ISNULL(r.start_location, '') + ' to ' + ISNULL(r.end_location, '')
ORDER BY avg_fuel_consumption;

CREATE TABLE gold.fleet_performance (
    vehicle_id INT,
    vehicle_type VARCHAR(50),
    total_distance_km FLOAT,
    avg_fuel_efficiency FLOAT,
    total_maintenance_events INT,
    total_trips INT,
    total_operational_days INT,
    utilization_rate FLOAT
);

INSERT INTO gold_db.fleet_performance (
    vehicle_id,
    vehicle_type,
    total_distance_km,
    avg_fuel_efficiency,
    total_maintenance_events,
    total_trips,
    total_operational_days,
    utilization_rate
)
SELECT
    vehicle_id,
    vehicle_type,
    SUM(CAST(distance_travelled_km AS FLOAT)) AS total_distance_km,
    ROUND(AVG(CAST(fuel_efficiency AS FLOAT)), 2) AS avg_fuel_efficiency,
    COUNT(maintenance_id) AS total_maintenance_events,
    COUNT(DISTINCT trip_id) AS total_trips,
    DATEDIFF(DAY, MIN(trip_date), MAX(trip_date)) + 1 AS total_operational_days,
    ROUND(COUNT(DISTINCT trip_id) * 1.0 / NULLIF(DATEDIFF(DAY, MIN(trip_date), MAX(trip_date)) + 1, 0), 2) AS utilization_rate
FROM silver_db.fleet_data
WHERE
    ISNUMERIC(distance_travelled_km) = 1
    AND ISNUMERIC(fuel_efficiency) = 1
GROUP BY
    vehicle_id, vehicle_type;


SELECT
    vehicle_id,
    COUNT(*) AS total_deliveries
FROM silver_db.delivery_data
GROUP BY vehicle_id;

INSERT INTO gold.fleet_delivery_summaryy (
    vehicle_id,
    total_deliveries
)
SELECT
    vehicle_id,
    COUNT(*) AS total_deliveries
FROM silver_db.delivery_data
GROUP BY vehicle_id;

CREATE TABLE gold.fleet_delivery_summary (
    VehicleID NVARCHAR(50),
    TotalDeliveries INT
);

INSERT INTO gold.fleet_delivery_summary (vehicle_id, TotalDeliveries)
SELECT
    vehicle_id,
    COUNT(*) AS TotalDeliveries
FROM silver_db.delivery_data
GROUP BY vehicle_id;

CREATE TABLE gold.total_deliveries_per_vehicle (
    vehicle_id NVARCHAR(50),
    total_deliveries int
);
  
CREATE TABLE gold.avg_distance_covered_per_vehicle (
    vehicle_type NVARCHAR(50),
    vg_distace_covered_per_vehicle float

insert into gold.avg_distance_covered_per_vehicle (vehicle_type,avg_distace_covered_per_vehicle)
select vehicle_type,
AVG(CAST(distance_covered AS FLOAT)) avg_distace_covered_per_vehicle
from [silver_db].[Silver_table]
group by vehicle_type





CREATE TABLE gold.avg_distance_covered_per_vehicle (
    vehicle_type NVARCHAR(50),
    avg_distance_covered_per_vehicle FLOAT
);

INSERT INTO gold.avg_distance_covered_per_vehicle (vehicle_type, avg_distance_covered_per_vehicle)
SELECT 
    vehicle_type,
    AVG(CAST(distance_covered AS FLOAT)) AS avg_distance_covered_per_vehicle
FROM 
    silver_db.Silver_table
GROUP BY 
    vehicle_type;

CREATE TABLE gold.avg_fuel_efficiency_per_vehicle (
    vehicle_type NVARCHAR(50),
    avg_fuel_efficiency FLOAT
);

INSERT INTO gold.avg_fuel_efficiency_per_vehicle (vehicle_type, avg_fuel_efficiency)
SELECT 
    vehicle_type,
    SUM(CAST(distance_covered AS FLOAT)) / NULLIF(SUM(CAST(fuel_consumed AS FLOAT)), 0) AS avg_fuel_efficiency
FROM 
    silver_db.Silver_table
GROUP BY 
    vehicle_type;

CREATE TABLE gold.driver_performance_summary (
    driver_id NVARCHAR(50),
    driver_name NVARCHAR(100),
    total_deliveries INT,
    avg_delivery_time FLOAT,
    avg_distance_per_delivery FLOAT,
    fuel_efficiency FLOAT
);

INSERT INTO gold.driver_performance_summary (
    driver_id,
    driver_name,
    total_deliveries,
    avg_delivery_time,
    avg_distance_per_delivery,
    fuel_efficiency
)
SELECT 
    driver_id,
    driver_name,
    COUNT(*) AS total_deliveries,
    AVG(CAST(delivery_time AS FLOAT)) AS avg_delivery_time,
    AVG(CAST(distance_covered AS FLOAT)) AS avg_distance_per_delivery,
    SUM(CAST(distance_covered AS FLOAT)) / NULLIF(SUM(CAST(fuel_consumed AS FLOAT)), 0) AS fuel_efficiency
FROM 
    silver_db.Silver_table
GROUP BY 
    driver_id, driver_name;
CREATE TABLE gold.driver_performance_summary1 (
    driver_name NVARCHAR(100),
    total_deliveries INT,
    avg_delivery_time FLOAT,
    avg_distance_per_delivery FLOAT,
    fuel_efficiency FLOAT
);

INSERT INTO gold.driver_performance_summary (
    driver_name,
    total_deliveries,
    avg_delivery_time,
    avg_distance_per_delivery,
    fuel_efficiency
)
SELECT 
    [driver_name] AS driver_name,
    COUNT([delivery_id]) AS total_deliveries,
    AVG(CAST([delivery_time] AS FLOAT)) AS avg_delivery_time,
    AVG(CAST([distance_covered] AS FLOAT)) AS avg_distance_per_delivery,
    SUM(CAST([distance_covered] AS FLOAT)) / NULLIF(SUM(CAST([fuel_consumed] AS FLOAT)), 0) AS fuel_efficiency
FROM 
    silver_db.Silver_table
GROUP BY 
    [driver_name];

INSERT INTO gold.total_deliveries_per_driver (driver_name, total_deliveries)
SELECT 
    driver_name AS driver_name,
    COUNT([delivery_id]) AS total_deliveries
FROM 
    silver_db.Silver_table
GROUP BY 
    [driver_name];

	CREATE TABLE gold.total_deliveries_per_driver (
    driver_name NVARCHAR(100),
    total_deliveries INT
);


INSERT INTO gold.avg_delivery_time_per_driver (driver_name, avg_delivery_time_minutes)
SELECT 
    [driver_name] AS driver_name,
    AVG(CAST([delivery_time] AS FLOAT)) AS avg_delivery_time_minutes
FROM 
    silver_db.Silver_table
GROUP BY 
    [driver_name];

CREATE TABLE gold.avg_delivery_time_per_driver (
    driver_name NVARCHAR(100),
    avg_delivery_time_minutes FLOAT

select * from[silver_db].[vechile_data]
);

CREATE TABLE gold.avg_driver_rating_per_driver (
    driver_name NVARCHAR(100),
    avg_driver_rating FLOAT
);
INSERT INTO gold.avg_driver_rating_per_driver (driver_name, avg_driver_rating)
SELECT 
    [driver_name],
    AVG(CAST([rating] AS FLOAT))
FROM 
    silver_db.vechile_data
GROUP BY 
    [driver_name];

	CREATE TABLE gold.route_optimization_summary (
    route NVARCHAR(100),
    avg_delivery_time FLOAT,
    total_deliveries INT,
    avg_distance_covered FLOAT,
    avg_fuel_consumed FLOAT,
    avg_fuel_efficiency FLOAT
);
INSERT INTO gold.route_optimization_summary (route, avg_delivery_time, total_deliveries, avg_distance_covered, avg_fuel_consumed, avg_fuel_efficiency)
SELECT 
    r.[route_name],
    r.avg_delivery_time,
    d.total_deliveries,
    f.avg_distance_covered,
    f.avg_fuel_consumed,
    f.avg_fuel_efficiency
FROM 
    (
        SELECT [route_name], AVG(CAST([delivery_time] AS FLOAT)) AS avg_delivery_time
        FROM silver_db.Silver_table
        GROUP BY [route_name]
    ) r
JOIN (
        SELECT [route_name], COUNT(*) AS total_deliveries
        FROM silver_db.Silver_table
        GROUP BY [route_name]
    ) d ON r.[route_name] = d.[route_name]
JOIN (
        SELECT 
            [route_name],
            AVG(CAST([distance_covered] AS FLOAT)) AS avg_distance_covered,
            AVG(CAST([fuel_consumed] AS FLOAT)) AS avg_fuel_consumed,
            (AVG(CAST([distance_covered] AS FLOAT)) / NULLIF(AVG(CAST([fuel_consumed] AS FLOAT)), 0)) AS avg_fuel_efficiency
        FROM silver_db.Silver_table
        GROUP BY [route_name]
    ) f ON r.[route_name] = f.[route_name];


CREATE TABLE gold.fleet_performance_summary (
    vehicle_id NVARCHAR(50),
    vehicle_type NVARCHAR(50),
    total_deliveries INT,
    avg_distance FLOAT,
    avg_fuel_consumed FLOAT,
    fuel_efficiency FLOAT,
    avg_delivery_time FLOAT
);
INSERT INTO gold.fleet_performance_summary (
    vehicle_id,
    vehicle_type,
    total_deliveries,
    avg_distance,
    avg_fuel_consumed,
    fuel_efficiency,
    avg_delivery_time
)
SELECT 
   
    [vehicle_type],
    COUNT([delivery_id]) AS total_deliveries,
    ROUND(AVG(CAST([distance_covered] AS FLOAT)), 2) AS avg_distance,
    ROUND(AVG(CAST([fuel_consumed] AS FLOAT)), 2) AS avg_fuel_consumed,
    ROUND(SUM(CAST([distance_covered] AS FLOAT)) / NULLIF(SUM(CAST([fuel_consumed] AS FLOAT)), 0), 2) AS fuel_efficiency,
    ROUND(AVG(CAST([delivery_time] AS FLOAT)), 2) AS avg_delivery_time
FROM 
    silver_db.Silver_table
GROUP BY 
    [vehicle_type];


SELECT
    a.route_name,
    COUNT(c.delivery_id) AS total_deliveries,
    AVG(CAST(a.delivery_time AS FLOAT)) AS avg_delivery_time,
    AVG(CAST(a.fuel_consumed AS FLOAT)) AS avg_fuel_consumed,
    SUM(CAST(a.distance_covered AS FLOAT)) AS total_distance,
    a.driver_name,
    COUNT(c.delivery_id) AS total_deliveries_by_driver,
    AVG(CAST(b.rating AS FLOAT)) AS driver_rating,
    TRY_CAST(c.delivery_date AS DATE) AS report_date
FROM silver_db.Silver_table a
JOIN silver_db.vechile_data b
    ON a.driver_name = b.driver_name
JOIN silver_db.delivery_data c
    ON a.delivery_id = c.delivery_id
WHERE TRY_CAST(c.delivery_date AS DATE) IS NOT NULL
GROUP BY
    a.route_name,
    a.driver_name,
    TRY_CAST(c.delivery_date AS DATE);


CREATE TABLE gold.transportation_gold (
    route_name VARCHAR(100),
    total_deliveries INT,
    avg_delivery_time FLOAT,
    avg_fuel_consumed FLOAT,
    total_distance FLOAT,
    driver_name VARCHAR(100),
    total_deliveries_by_driver INT,
    driver_rating FLOAT,
    report_date DATE
);
INSERT INTO gold.transportation_gold (
    route_name,
    total_deliveries,
    avg_delivery_time,
    avg_fuel_consumed,
    total_distance,
    driver_name,
    total_deliveries_by_driver,
    driver_rating,
    report_date
)
SELECT
    a.route_name,
    COUNT(c.delivery_id) AS total_deliveries,
    AVG(CAST(a.delivery_time AS FLOAT)) AS avg_delivery_time,
    AVG(CAST(a.fuel_consumed AS FLOAT)) AS avg_fuel_consumed,
    SUM(CAST(a.distance_covered AS FLOAT)) AS total_distance,
    a.driver_name,
    COUNT(c.delivery_id) AS total_deliveries_by_driver,
    AVG(CAST(b.rating AS FLOAT)) AS driver_rating,
    TRY_CAST(c.delivery_date AS DATE) AS report_date
FROM silver_db.Silver_table a
JOIN silver_db.vechile_data b
    ON a.driver_name = b.driver_name
JOIN silver_db.delivery_data c
    ON a.delivery_id = c.delivery_id
WHERE TRY_CAST(c.delivery_date AS DATE) IS NOT NULL
GROUP BY
    a.route_name,
    a.driver_name,
    TRY_CAST(c.delivery_date AS DATE);







select * from	[silver_db].[Silver_table]		 
select * from  [silver_db].[driver_data]