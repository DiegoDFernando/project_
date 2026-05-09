
--Q1 Which countries are included in the dataset?
SELECT DISTINCT country_name AS 'Paises'
FROM dim_country1

--Q2 What is the total number of units sold per country?
SELECT country_name, SUM(mm.units_sold) AS 'Total_ventas'
FROM dim_country1 AS dc
INNER JOIN ev_market_master1 AS mm ON dc.country_id = mm.country_id
GROUP BY country_name
ORDER BY Total_ventas DESC

--Q3 What are the 3 months with the highest global sales?
SELECT TOP 3
    dd.year, dd.month,
    SUM(mm.units_sold) AS 'total_ventas'
FROM ev_market_master1 AS mm
INNER JOIN dim_date AS dd ON mm.date_id = dd.date_id
GROUP BY dd.year, dd.month
ORDER BY total_ventas DESC

--Q4 Which country had the highest average gasoline price?
SELECT dc.country_name, dd.year,
    ROUND(AVG(fpm.gasoline_price_usd_per_liter), 2) AS 'precio_promedio_gasolina'
FROM dim_country1 AS dc
INNER JOIN fuel_prices_monthly1 AS fpm ON dc.country_id = fpm.country_id
INNER JOIN dim_date AS dd ON dd.date_id = fpm.date_id
WHERE dd.year BETWEEN 2019 AND 2023
GROUP BY dc.country_name, dd.year
ORDER BY precio_promedio_gasolina DESC

--Q5 How many fast chargers does each country have accumulated by the end of 2023?
SELECT dc.country_name,
    MAX(cm.fast_chargers_cumulative) AS 'total_cargadores_rapidos'
FROM dim_country1 AS dc
INNER JOIN ev_charging_monthly1 AS cm ON dc.country_id = cm.country_id
INNER JOIN dim_date AS dd ON cm.date_id = dd.date_id
WHERE dd.year = 2023
GROUP BY dc.country_name
ORDER BY total_cargadores_rapidos DESC

--Q6 Which brand among BYD, Tesla and VW had the highest total sales by country?
WITH ventas_totales AS (
    SELECT dc.country_name, db.brand_name,
        SUM(mm.units_sold) AS 'total_ventas',
        RANK() OVER (PARTITION BY country_name 
                     ORDER BY SUM(mm.units_sold) DESC) AS ranking
    FROM dim_brand AS db
    INNER JOIN ev_market_master1 AS mm ON db.brand_id = mm.brand_id
    INNER JOIN dim_country1 AS dc ON mm.country_id = dc.country_id
    WHERE db.brand_name IN ('BYD', 'Tesla', 'VW')
    GROUP BY db.brand_name, dc.country_name
)
SELECT * FROM ventas_totales
WHERE ranking = 1
ORDER BY total_ventas DESC

--Q7 In which months did Google search interest for "electric car" exceed a score of 75?
SELECT dc.country_name, dk.keyword, dd.year, dd.month,
    evm.trend_score AS 'puntaje'
FROM dim_keyword AS dk
INNER JOIN ev_trends_monthly1 AS evm ON dk.keyword_id = evm.keyword_id
INNER JOIN dim_date AS dd ON evm.date_id = dd.date_id
INNER JOIN dim_country1 AS dc ON evm.country_id = dc.country_id
WHERE dk.keyword = 'electric car' AND evm.trend_score > 75
ORDER BY puntaje DESC

--Q8 Which country had the highest average year-on-year (YoY) growth?
WITH ventas_anuales AS (
    SELECT dc.country_name, dd.year,
        AVG(mm.units_sold) AS 'promedio_ventas'
    FROM ev_market_master1 AS mm
    INNER JOIN dim_date AS dd ON mm.date_id = dd.date_id
    INNER JOIN dim_country1 AS dc ON dc.country_id = mm.country_id
    GROUP BY dc.country_name, dd.year
),
yoy AS (
    SELECT country_name, year, promedio_ventas,
        LAG(promedio_ventas) OVER (PARTITION BY country_name 
                                   ORDER BY year) AS prev_year,
        ROUND((promedio_ventas - LAG(promedio_ventas) OVER 
              (PARTITION BY country_name ORDER BY year)) * 100.0 /
        NULLIF(LAG(promedio_ventas) OVER 
              (PARTITION BY country_name ORDER BY year), 0), 2) AS promedio_crecimiento
    FROM ventas_anuales
)
SELECT TOP 1 * FROM yoy
ORDER BY promedio_crecimiento DESC

--Q9 Which keyword had the highest average search volume per country?
WITH keyword_promedio AS (
    SELECT dc.country_name, dk.keyword,
        ROUND(AVG(tt.trend_score), 2) AS 'promedio_busqueda'
    FROM dim_keyword AS dk
    INNER JOIN ev_trends_monthly1 AS tt ON dk.keyword_id = tt.keyword_id
    INNER JOIN dim_country1 AS dc ON tt.country_id = dc.country_id
    GROUP BY dc.country_name, dk.keyword
),
ranking AS (
    SELECT *,
        RANK() OVER (PARTITION BY country_name 
                     ORDER BY promedio_busqueda DESC) AS 'rank'
    FROM keyword_promedio
)
SELECT * FROM ranking
WHERE rank = 1
ORDER BY promedio_busqueda DESC

--Q10 — Which month had the biggest jump in sales by country?
WITH ventas_actuales AS (
    SELECT dc.country_name, dd.year, dd.month,
        SUM(mm.units_sold) AS 'total_ventas'
    FROM ev_market_master1 AS mm
    INNER JOIN dim_date AS dd ON mm.date_id = dd.date_id
    INNER JOIN dim_country1 AS dc ON mm.country_id = dc.country_id
    GROUP BY dc.country_name, dd.year, dd.month
),
ventas_anteriores AS (
    SELECT country_name, year, month, total_ventas,
        LAG(total_ventas) OVER (PARTITION BY country_name 
                                ORDER BY year, month) AS anterior,
        ROUND(total_ventas - LAG(total_ventas) OVER 
             (PARTITION BY country_name ORDER BY year, month), 2) AS diferencia
    FROM ventas_actuales
),
ranking AS (
    SELECT *,
        RANK() OVER (PARTITION BY country_name 
                     ORDER BY diferencia DESC) AS ranking_pais
    FROM ventas_anteriores
)
SELECT country_name, month AS mes, total_ventas,
       anterior AS 'ventas_anterior', diferencia, ranking_pais
FROM ranking
WHERE ranking_pais = 1
ORDER BY diferencia DESC

--Q11 — Which country had the month with the biggest drop in sales?
WITH ventas_mensuales AS (
    SELECT dc.country_name, dd.year, dd.month,
        SUM(mm.units_sold) AS 'total_ventas'
    FROM ev_market_master1 AS mm
    INNER JOIN dim_date AS dd ON mm.date_id = dd.date_id
    INNER JOIN dim_country1 AS dc ON mm.country_id = dc.country_id
    GROUP BY dc.country_name, dd.year, dd.month
),
con_lag AS (
    SELECT country_name, year, month, total_ventas,
        LAG(total_ventas) OVER (PARTITION BY country_name 
                                ORDER BY year, month) AS anterior,
        ROUND(total_ventas - LAG(total_ventas) OVER 
             (PARTITION BY country_name ORDER BY year, month), 2) AS diferencia
    FROM ventas_mensuales
),
ranking AS (
    SELECT *,
        RANK() OVER (PARTITION BY country_name 
                     ORDER BY diferencia ASC) AS ranking_caida
    FROM con_lag
    WHERE diferencia IS NOT NULL
)
SELECT country_name, year, month AS mes,
       total_ventas, anterior, diferencia
FROM ranking
WHERE ranking_caida = 1
ORDER BY diferencia ASC

--Q12 — Which country had the highest percentage of EV sales in the year with the most global sales?
WITH ventas_anuales AS (
    SELECT dc.country_name, dd.year,
        SUM(mm.units_sold) AS 'ventas_pais'
    FROM ev_market_master1 AS mm
    INNER JOIN dim_country1 AS dc ON mm.country_id = dc.country_id
    INNER JOIN dim_date AS dd ON mm.date_id = dd.date_id
    GROUP BY dc.country_name, dd.year
),
total_por_anio AS (
    SELECT year, SUM(ventas_pais) AS 'ventas_globales'
    FROM ventas_anuales
    GROUP BY year
),
mejor_anio AS (
    SELECT TOP 1 year FROM total_por_anio
    ORDER BY ventas_globales DESC
),
porcentaje AS (
    SELECT va.country_name, va.year, va.ventas_pais,
        tp.ventas_globales,
        ROUND(va.ventas_pais * 100.0 / tp.ventas_globales, 2) AS 'porcentaje'
    FROM ventas_anuales AS va
    INNER JOIN total_por_anio AS tp ON va.year = tp.year
    WHERE va.year = (SELECT year FROM mejor_anio)
)
SELECT country_name, year, ventas_pais,
       ventas_globales, porcentaje
FROM porcentaje
ORDER BY porcentaje DESC