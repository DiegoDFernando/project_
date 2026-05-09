# Data Analysis with SQL Server and Python - EV Market Intelligence: Sales, Trends & Infrastructure Analysis (2019–2023) - Project

Author: Diego Fernando Delgado

Project Type: EV Market Demand Forecast Dataset (Sales + Trends + Infrastructure)
Dataset Source: Kaggle — EV Market Demand Forecast Dataset

Project Overview:

This project delivers a comprehensive monthly dataset and full-cycle data analytics pipeline focused on global Electric Vehicle (EV) market dynamics across 8 countries  China, USA, Germany, UK, France, Norway, Netherlands, and India from 2019 to 2023. The dataset combines EV sales data, consumer interest signals, charging infrastructure, and fuel prices to support demand forecasting, market analysis, and time-series modeling. Starting from raw CSV files, the project includes data cleaning, relational database design, SQL analysis, and business intelligence visualization, transforming scattered multi-source data into actionable market insights.

Key Objetives:

Data Cleaning and Preparation: Standardize and clean raw multisource CSV files using Excel.
Database Design: Create a normalized relational schema in SQL Server with appropriate primary and foreign keys.
SQL Analysis: Answer 12 business questions using queries ranging from basic aggregations to advanced window functions.
Business Intelligence: Create professional dashboards in Python (Jupyter).

Dataset Description:
ev_market_master.csv -- Main merged dataset (420 rows × 25 columns)ev_sales_brands.csv -- Brand-level sales (BYD, Tesla, VW)
ev_trends_monthly.csv -- Google Trends by keyword and country
ev_charging_monthly.csv -- Charging infrastructure by countryyear
ev_fuel_prices_monthly.csv -- Monthly gasoline prices by country

Database Schema:
Normalization Process
Raw multi-source CSV files were cleaned and structured in Excel, where primary keys and IDs were created before loading into SQL Server.

<img width="1348" height="762" alt="definitivo" src="https://github.com/user-attachments/assets/2458c686-35cc-40c2-9ea4-0facbcce3d27" />

Key design decisions

Surrogate keys (country_id, brand_id, date_id, keyword_id, drivetrain_id) were created in Excel before being imported into SQL Server.
All fact tables reference dimension tables using foreign keys.
A star schema design was used, with ev_market_master1 as the central fact table.
Dimension tables are prefixed with dim_ for clear identification.

Key Findings & Business Insights

-Market Dominance
China accounts for 63.5% of total global EV sales across 2019–2023, far ahead of all other markets
USA is the second largest market at 18.9%, followed by UK (6.2%) and France (6.1%)

-Fuel Price Context
Netherlands has the highest average gasoline price across the period, followed by France and Norway
Higher fuel prices correlate with stronger EV adoption trends in European markets

-Charging Infrastructure
United Kingdom leads in fast charger deployment with 11,000 units by end of 2023
Norway follows with 2,900 fast chargers — notable given its much smaller population

-Search Interest (Google Trends)
The keyword "electric car" consistently shows the highest search interest across all countries
Search interest spikes tend to precede sales increases, suggesting trends data can be used for demand forecasting

-Brand Performance
BYD dominates in China and Asian markets
Tesla leads in USA and most Western markets
VW shows strength in European markets

-Market Volatility
China recorded the largest monthly sales drop (-468K units in February 2022), reflecting post-holiday seasonal patterns
China also recorded the largest monthly sales jump, showing extreme seasonality in the world's largest EV market

-Best Year Performance
2023 was the best year globally for EV sales
China contributed the highest percentage of global sales that year, reinforcing its market dominance
