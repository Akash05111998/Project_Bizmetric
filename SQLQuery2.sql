select * from [silver_db].[route_data]

INSERT INTO gold.avg_fuel_consumption_per_route (route_name, avg_fuel_consumption)
SELECT 
    ISNULL(r.start_location, '') + ' to ' + ISNULL(r.end_location, '') AS route_name,
    ROUND(AVG(CAST(d.distance_covered AS FLOAT) / NULLIF(CAST(v.fuel_efficiency AS FLOAT), 0)), 2) AS avg_fuel_consumption
FROM silver_db.delivery_data d
JOIN silver_db.route_data r ON d.route_id = r.route_id
JOIN silver_db.vehicle_data v ON d.vehicle_id = v.vehicle_id
WHERE v.fuel_efficiency IS NOT NULL AND d.distance_covered IS NOT NULL
GROUP BY ISNULL(r.start_location, '') + ' to ' + ISNULL(r.end_location, '')
ORDER BY avg_fuel_consumption;
select *from[silver_db].[delivery_data]
use gold

select * from[gold].[fleet_avg_distance1]


CREATE TABLE gold.fleet_performance2 (
    
    vehicle_type NVARCHAR(100),
    total_deliveries INT,
    total_distance FLOAT,
    fuel_efficiency FLOAT
);

INSERT INTO gold.fleet_performance2 ( vehicle_type, total_deliveries, total_distance, fuel_efficiency)
SELECT 
    
    vehicle_type,
    COUNT(delivery_id) AS total_deliveries,
    SUM(CAST(distance_covered AS FLOAT)) AS total_distance,
    AVG(CAST(distance_covered AS FLOAT) / NULLIF(CAST(fuel_consumed AS FLOAT), 0)) AS fuel_efficiency
FROM silver_db.Silver_table
WHERE ISNUMERIC(distance_covered) = 1 AND ISNUMERIC(fuel_consumed) = 1
GROUP BY  vehicle_type;

select * from [gold].[transportation_gold] 