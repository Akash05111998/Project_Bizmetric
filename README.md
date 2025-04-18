This project processes, transforms, and visualizes transportation and logistics data using PySpark, MySQL, and Power BI following the Medallion Architecture. 
It generates key insights on delivery efficiency, route optimization, and fleet performance.


1. Bronze Layer
Raw CSV files converted to Parquet format

Stored with audit columns (e.g., source_file, ingestion_date)

2. Silver Layer
Data cleaned, enriched, and joined

Additional computed columns like fuel_consumed = distance_covered / fuel_efficiency

3. Gold Layer
Aggregated metrics stored in gold_db.transportation_gold

Used as the Power BI data source

4.Visualizations:
  Route Optimization – Line chart: Avg delivery time & fuel consumption per route
  
  Fleet Performance – Bar chart: Deliveries vs fuel efficiency per vehicle
  
  Driver Performance – Scatter plot: Deliveries vs driver rating
  
  Delivery Status – Pie chart: Completed vs Failed
  
  Time Trends – Line chart: Weekly/monthly delivery trends
  
  Data Source: Connected to MySQL Gold Layer (gold_db.transportation_gold)
