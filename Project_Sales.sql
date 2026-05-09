CREATE DATABASE salesproject

USE salesproject

ALTER TABLE dim_country1 ALTER COLUMN country_id INT NOT NULL
ALTER TABLE dim_country1 ALTER COLUMN country_name NVARCHAR (100)
ALTER TABLE dim_country1 ALTER COLUMN geo_code NVARCHAR(10)

ALTER TABLE dim_country1 ADD CONSTRAINT PK_dim_country1 PRIMARY KEY (country_id)

ALTER TABLE ev_charging_monthly1 ALTER COLUMN charging_id INT NOT NULL
ALTER TABLE ev_charging_monthly1 ALTER COLUMN country_id INT
ALTER TABLE ev_charging_monthly1 ALTER COLUMN slow_chargers_cumulative BIGINT
ALTER TABLE ev_charging_monthly1 ALTER COLUMN fast_chargers_cumulative BIGINT
ALTER TABLE ev_charging_monthly1 ALTER COLUMN total_chargers_cumulative BIGINT

ALTER TABLE ev_charging_monthly1
ADD CONSTRAINT PK_ev_charging_monthly1 PRIMARY KEY (charging_id)

ALTER TABLE ev_charging_monthly1
ADD CONSTRAINT FK_ev_charging_country 
FOREIGN KEY (country_id) REFERENCES dim_country1(country_id)

ALTER TABLE ev_market_master1 ALTER COLUMN market_id INT NOT NULL
ALTER TABLE ev_market_master1 ALTER COLUMN country_id INT
ALTER TABLE ev_market_master1 ALTER COLUMN date DATE
ALTER TABLE ev_market_master1 ALTER COLUMN units_sold FLOAT
ALTER TABLE ev_market_master1 ALTER COLUMN trend_byd FLOAT
ALTER TABLE ev_market_master1 ALTER COLUMN trend_ev_charging FLOAT
ALTER TABLE ev_market_master1 ALTER COLUMN trend_tesla FLOAT
ALTER TABLE ev_market_master1 ALTER COLUMN trend_electric_car FLOAT
ALTER TABLE ev_market_master1 ALTER COLUMN trend_electric_vehicle FLOAT
ALTER TABLE ev_market_master1 ALTER COLUMN slow_chargers_cumulative BIGINT
ALTER TABLE ev_market_master1 ALTER COLUMN fast_chargers_cumulative BIGINT
ALTER TABLE ev_market_master1 ALTER COLUMN total_chargers_cumulative BIGINT
ALTER TABLE ev_market_master1 ALTER COLUMN gasoline_price_usd_per_liter FLOAT
ALTER TABLE ev_market_master1 ALTER COLUMN units_sold_lag1 FLOAT
ALTER TABLE ev_market_master1 ALTER COLUMN units_sold_lag3 FLOAT
ALTER TABLE ev_market_master1 ALTER COLUMN units_sold_lag12 FLOAT
ALTER TABLE ev_market_master1 ALTER COLUMN units_sold_yoy_growth FLOAT
ALTER TABLE ev_market_master1 ALTER COLUMN quarter INT

ALTER TABLE ev_market_master1
ADD CONSTRAINT PK_ev_market_master1 PRIMARY KEY (market_id)

ALTER TABLE ev_market_master1
ADD CONSTRAINT FK_market_country
FOREIGN KEY (country_id) REFERENCES dim_country1(country_id)


ALTER TABLE fuel_prices_monthly1 ALTER COLUMN price_id INT NOT NULL
ALTER TABLE fuel_prices_monthly1 ALTER COLUMN country_id INT
ALTER TABLE fuel_prices_monthly1 ALTER COLUMN date DATE
ALTER TABLE fuel_prices_monthly1 ALTER COLUMN gasoline_price_usd_per_liter FLOAT

ALTER TABLE fuel_prices_monthly1
ADD CONSTRAINT PK_fuel_prices PRIMARY KEY (price_id)

ALTER TABLE fuel_prices_monthly1
ADD CONSTRAINT FK_fuel_country
FOREIGN KEY (country_id) REFERENCES dim_country1(country_id)


ALTER TABLE ev_trends_monthly1 ALTER COLUMN trend_id INT NOT NULL
ALTER TABLE ev_trends_monthly1 ALTER COLUMN country_id INT
ALTER TABLE ev_trends_monthly1 ALTER COLUMN date DATE
ALTER TABLE ev_trends_monthly1 ALTER COLUMN trend_score FLOAT

ALTER TABLE ev_trends_monthly1
ADD CONSTRAINT PK_ev_trends PRIMARY KEY (trend_id)

ALTER TABLE ev_trends_monthly1
ADD CONSTRAINT FK_trends_country
FOREIGN KEY (country_id) REFERENCES dim_country1(country_id)

SELECT * FROM dim_country1
SELECT * FROM ev_charging_monthly1 
SELECT * FROM ev_market_master1
SELECT * FROM fuel_prices_monthly1
SELECT * FROM ev_trends_monthly1


ALTER TABLE ev_trends_monthly1
DROP COLUMN geo_code


--Total Vehiculos Vendidos

SELECT SUM(units_sold) as 'total_vendidos_global'
FROM ev_market_master1

--Pais con mayor crecimiento 2019 vs 2023

SELECT * FROM ma