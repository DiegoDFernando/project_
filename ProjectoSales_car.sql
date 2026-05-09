USE salesproject

ALTER TABLE dim_brand ALTER COLUMN brand_name NVARCHAR(50)
ALTER TABLE dim_country1 ALTER COLUMN country_name NVARCHAR(100)
ALTER TABLE dim_country1 ALTER COLUMN geo_code NVARCHAR(10)
ALTER TABLE dim_date ALTER COLUMN date DATE

ALTER TABLE ev_market_master1  
ALTER COLUMN units_sold FLOAT

SELECT * FROM dim_brand
SELECT * FROM dim_country1
SELECT * FROM dim_date
SELECT * FROM dim_drivetrain_type
SELECT * FROM dim_keyword
SELECT * FROM ev_charging_monthly1
SELECT * FROM ev_market_master1
SELECT * FROM ev_trends_monthly1
SELECT * FROM  fuel_prices_monthly1

-- 1. Total de unidades vendidas 
SELECT SUM(units_sold) as 'total_ventas' FROM ev_market_master1

-- 2. ¿Cuántos países distintos tienen datos de ventas?
SELECT COUNT(DISTINCT(country_name)) as 'Paises' FROM dim_country1

-- 3. Ventas totales por marca

SELECT db.brand_name, SUM(mm.units_sold) 
as 'total_ventas'
FROM ev_market_master1 as mm 
 INNER JOIN 
	dim_brand as db ON mm.brand_id = db.brand_id
GROUP BY db.brand_name
ORDER BY total_ventas DESC

--4. ¿Cuál es el precio promedio de gasolina de cada país en todo el histórico?

SELECT dc.country_name ,AVG(fpm.gasoline_price_usd_per_liter) as 'precio_promedio_gasolina' FROM  fuel_prices_monthly1 as fpm
INNER JOIN 
	dim_country1 as dc ON fpm.country_id = dc.country_id
GROUP BY dc.country_name
ORDER BY precio_promedio_gasolina DESC

--5. ¿Cuántos cargadores tiene cada país en total?

SELECT dc.country_name, 
MAX(cm.total_chargers_cumulative) as 'total_cargadores',
MAX(cm.fast_chargers_cumulative) as 'cargadores_rapidos',
MAX(cm.slow_chargers_cumulative) as 'cargadores_lentos'
FROM ev_charging_monthly1 as cm 
INNER JOIN 
	dim_country1 as dc ON cm.country_id = dc.country_id
GROUP BY dc.country_name
ORDER BY total_cargadores DESC

--6. Ventas por país y año
--¿Cuántas unidades eléctricas se vendieron por país en cada año /DESC?

SELECT dc.country_name,dd.year,
SUM(mm.units_sold) as 'total_ventas' 
FROM  dim_date as dd
INNER JOIN 
	ev_market_master1 as mm ON dd.date_id = mm.date_id
INNER JOIN	
	dim_country1 as dc ON dc.country_id = mm.country_id
GROUP BY dc.country_name,dd.year
ORDER BY SUM(mm.units_sold) DESC

--7. Top 3 marcas con más ventas por país (RANK)

SELECT db.brand_name, 
dc.country_name, 
SUM(mm.units_sold) as 'total_ventas',
RANK() OVER(PARTITION BY dc.country_name ORDER BY SUM(mm.units_sold) DESC) AS ranking
FROM dim_brand as db
INNER JOIN 
	ev_market_master1 as mm ON db.brand_id = mm.brand_id
INNER JOIN 
	dim_country1 as dc ON mm.country_id = dc.country_id
GROUP BY db.brand_name, dc.country_name
ORDER BY dc.country_name ,ranking DESC

--8. Evolución mensual de cargadores 

ALTER TABLE ev_charging_monthly1 ALTER COLUMN total_chargers_cumulative FLOAT

SELECT dc.country_name,dd.year,dd.month,
MAX(cm.fast_chargers_cumulative) as fast_chargers, 
MAX(cm.slow_chargers_cumulative) as slow_chargers,
MAX(cm.total_chargers_cumulative) as total_chargers
FROM ev_charging_monthly1 as cm
INNER JOIN
	dim_date as dd ON cm.date_id = dd.date_id
INNER JOIN 
	dim_country1 as dc ON dc.country_id = cm.country_id
GROUP BY dc.country_name,dd.year, dd.month
ORDER BY dc.country_name,dd.year, dd.month 

--9. Precio promedio de gasolina por país y año

ALTER TABLE fuel_prices_monthly1 ALTER COLUMN gasoline_price_usd_per_liter FLOAT

SELECT dc.country_name, dd.year,
ROUND(AVG(fpm.gasoline_price_usd_per_liter),2) as 'precio_promedio_gasolina',
MAX(fpm.gasoline_price_usd_per_liter) as 'precio_max_gasolina',
MIN(fpm.gasoline_price_usd_per_liter) as 'precio_min_gasolina'
FROM  fuel_prices_monthly1 as fpm
INNER JOIN 
	dim_country1 as dc ON  fpm.country_id = dc.country_id
INNER JOIN 
	dim_date as dd ON fpm.date_id = dd.date_id
GROUP BY dc.country_name, dd.year
ORDER BY precio_promedio_gasolina DESC

--10. Correlación entre precio de gasolina y ventas EV
--¿Los países con gasolina más cara venden más autos eléctricos?

SELECT dc.country_name,
dd.year,
AVG(fpm.gasoline_price_usd_per_liter) as 'promedio_total_gasolina',
SUM(mm.units_sold) as 'total_ventas'
FROM fuel_prices_monthly1 as fpm
INNER JOIN
	ev_market_master1 as mm ON fpm.country_id = mm.country_id 
INNER JOIN	
	dim_country1 as dc ON dc.country_id = fpm.country_id
INNER JOIN 
	dim_date as dd ON dd.date_id = fpm.date_id
GROUP BY  dc.country_name,dd.year
ORDER BY promedio_total_gasolina DESC

--11. Tendencia de búsqueda por keyword y país
--¿Qué tan popular es la búsqueda de cada marca en cada país a lo largo del tiempo?

ALTER TABLE ev_trends_monthly1 ALTER COLUMN trend_score FLOAT

SELECT dk.keyword,dc.country_name,dd.year,
dd.month,
AVG(tm.trend_score) as 'promedio_busqueda'
FROM  dim_keyword as dk 
INNER JOIN 
	ev_trends_monthly1 as tm ON dk.keyword_id = tm.keyword_id
INNER JOIN 
	dim_country1 as dc ON tm.country_id = dc.country_id
INNER JOIN	
	dim_date as dd ON tm.date_id = dd.date_id
GROUP BY  dk.keyword,dc.country_name,dd.year,dd.month
ORDER BY dk.keyword,dc.country_name,dd.year,dd.month

--12. Países sin ventas EV 
--¿Hay paises en la tabla de paises que NO tienen registros de Ventas EV?

SELECT dc.country_name,
dc.geo_code,
COUNT(mm.market_id) as 'cantidad_ventas'
FROM dim_country1 as dc
LEFT JOIN 
	ev_market_master1 as mm ON dc.country_id = mm.country_id
GROUP BY dc.country_name, dc.geo_code
ORDER BY cantidad_ventas ASC

--13. Acumulado histórico por país
--Cuál es el acumulado histórico de ventas EV por país?

SELECT dc.country_name,
SUM(mm.units_sold) as 'total_ventas',
MAX(mm.units_sold) as 'ventas_maxima',
MIN(mm.units_sold) as 'ventas_min',
AVG(mm.units_sold) as 'promedio_ventas'
FROM dim_country1 as dc
INNER JOIN 
	ev_market_master1 as mm ON dc.country_id = mm.country_id
INNER JOIN 
	dim_date as dd ON mm.date_id = dd.date_id
GROUP BY dc.country_name
ORDER BY total_ventas DESC

--14. ¿El precio de gasolina de cada mes es bajo, normal o alto comparado con el promedio histórico del país?

SELECT dc.country_name, dd.month ,
ROUND(fpm.gasoline_price_usd_per_liter, 2) as 'gasolina_precio',
ROUND(AVG(fpm.gasoline_price_usd_per_liter) OVER (PARTITION BY dc.country_name), 3) AS avg_price_country,
CASE 
WHEN fpm.gasoline_price_usd_per_liter > AVG(fpm.gasoline_price_usd_per_liter) OVER (PARTITION BY dc.country_name) * 1.15 THEN 'precio_alto'
WHEN fpm.gasoline_price_usd_per_liter < AVG(fpm.gasoline_price_usd_per_liter) OVER (PARTITION BY dc.country_name)  * 0.85 THEN 'precio_bajo'
ELSE 'precio_normal'
END as precio_gasolina
FROM fuel_prices_monthly1 as  fpm
INNER JOIN
	dim_country1 as dc ON fpm.country_id = dc.country_id
INNER JOIN  
	dim_date as dd ON fpm.date_id = dd.date_id
ORDER BY gasolina_precio DESC


-- 15. Ranking anual de países con CTE
--¿Qué países crecieron más en ventas EV y cuál es su ranking histórico?

WITH ventas_anuales AS (
SELECT dc.country_name,
dd.year,
SUM(mm.units_sold) as 'ventas_totales'
FROM dim_country1 as dc
INNER JOIN 
 ev_market_master1 as mm ON dc.country_id = mm.country_id
INNER JOIN  
 dim_date as dd ON dd.date_id = mm.date_id
GROUP BY  dc.country_name, dd.year 

),
ranking_year AS (
SELECT country_name,year,
ventas_totales,
RANK() OVER (PARTITION BY year ORDER BY ventas_totales DESC) as rank_anual 
FROM ventas_anuales
)

SELECT TOP 5 * FROM ranking_year
WHERE rank_anual < 6
ORDER BY  year,rank_anual

--16. Ventas EV por país con etiquetas de rendimiento 
SELECT dc.country_name as 'pais',
SUM(mm.units_sold) as 'ventas_totales',
CASE
WHEN SUM(mm.units_sold) >= 1000000 THEN  'Alto'
WHEN SUM(mm.units_sold) >=100000 THEN 'Medio'
ELSE 'Bajo'
END as 'rendimiento'
FROM  dim_country1 as dc
INNER JOIN 
	ev_market_master1 as mm ON dc.country_id = mm.country_id
GROUP BY dc.country_name
ORDER BY ventas_totales DESC

--17. Top 3 marcas por año (WITH + RANK)

WITH ventas_anuales AS(
SELECT db.brand_name, dd.year,
SUM(mm.units_sold) as 'ventas_totales'
FROM dim_brand as db
INNER JOIN 
	ev_market_master1 as mm ON db.brand_id = mm.brand_id
INNER JOIN 
	dim_date as dd ON mm.date_id = dd.date_id
GROUP BY  db.brand_name, dd.year
),

ranking as (
SELECT brand_name,
year,
ventas_totales,
RANK() OVER (PARTITION BY year ORDER BY ventas_totales DESC) as 'posición'
FROM ventas_anuales
)

SELECT * FROM ranking
WHERE posición <=3
ORDER BY year, posición

--18. Países con ventas EV pero sin precio de gasolina

SELECT dc.country_name,year, 
AVG(fpm.gasoline_price_usd_per_liter) as'promedio_gasolina' ,
MAX(fpm.gasoline_price_usd_per_liter) as 'precio_max',
MIN(fpm.gasoline_price_usd_per_liter) as 'min_precio',
CASE
WHEN AVG(fpm.gasoline_price_usd_per_liter) IS NULL THEN 'Sin datos'
ELSE 'completo'
END as promedio_precios
FROM ev_market_master1  as mm
INNER JOIN
	dim_country1 as dc ON dc.country_id = mm.country_id
INNER JOIN 
	dim_date as dd ON mm.date_id = dd.date_id
LEFT JOIN	 
	 fuel_prices_monthly1 as fpm ON fpm.country_id = mm.country_id AND fpm.date_id = mm.date_id
GROUP BY dc.country_name,year
ORDER BY  promedio_gasolina DESC

--19. de participacion de cada marca en el mercado total
WITH ventas_marca as (
SELECT db.brand_name, SUM(mm.units_sold) as 'total_ventas'
FROM ev_market_master1 as  mm
INNER JOIN 
	dim_brand as db ON mm.brand_id = db.brand_id
INNER JOIN
	dim_date as dd ON mm.date_id = dd.date_id
GROUP BY db.brand_name

)

SELECT brand_name,total_ventas,
ROUND(total_ventas * 100 / (SELECT SUM(total_ventas) FROM ventas_marca) ,2) as 'porcentaje'
FROM ventas_marca
ORDER BY porcentaje DESC


--20. ¿Qué meses de cada año superaron el promedio mensual de ventas EV de ese mismo año?

WITH anual_ventas as(
SELECT dc.country_name,year,dd.month, ROUND(SUM(mm.units_sold),2) as 'ventas_totales'
FROM ev_market_master1 as mm 
	INNER JOIN 
		dim_date as dd ON mm.date_id = dd.date_id
	INNER JOIN 
		dim_country1 as dc ON mm.country_id = dc.country_id
GROUP BY dc.country_name ,dd.year,dd.month 

),
promedio_mensual as (
SELECT country_name,year, AVG(ventas_totales) as 'promedio_ventas'
FROM  anual_ventas
GROUP BY country_name, year

) 

SELECT av.country_name,
av.year,
av.month,
av.ventas_totales,
ROUND(pm.promedio_ventas, 2) as 'prom_ventas',
av.ventas_totales - pm.promedio_ventas as 'diferencia'
FROM anual_ventas as av
INNER JOIN  
	promedio_mensual as pm ON av.country_name = pm.country_name 
WHERE av.ventas_totales > pm.promedio_ventas
ORDER BY av.country_name, av.year , av.month

--21. Ratio de cargadores rápidos vs lentos por país
--¿Qué países tienen mejor infraestructura de carga rápida?

SELECT dc.country_name,
MAX(cm.total_chargers_cumulative) as 'total_carga',
MAX(cm.fast_chargers_cumulative) as 'max_carga',
ROUND(MAX(cm.fast_chargers_cumulative) * 100 /MAX(cm.total_chargers_cumulative),2) as 'porcentaje'
FROM ev_charging_monthly1 as cm
INNER JOIN 
	 dim_country1 as dc ON cm.country_id = dc.country_id
GROUP BY dc.country_name
ORDER BY total_carga DESC

--22. Marca dominante por país y año
--¿Qué marca vendió más en cada país en cada año?

WITH ventas_anuales as(
SELECT dc.country_name, db.brand_name, dd.year, SUM(mm.units_sold) as 'ventas_totales'
FROM dim_country1 as dc 
INNER JOIN
	ev_market_master1 as mm ON dc.country_id = mm.country_id
INNER JOIN	
	dim_date as dd ON mm.date_id = dd.date_id
INNER JOIN 
	dim_brand as db ON mm.brand_id = db.brand_id
GROUP BY dc.country_name, db.brand_name, dd.year

), 

ranking as(
SELECT country_name, brand_name, year
,ventas_totales,
RANK () OVER (PARTITION BY country_name, year ORDER BY ventas_totales DESC) as 'rank_general'
FROM ventas_anuales

)

SELECT * FROM ranking
WHERE rank_general = 1
ORDER BY ventas_totales DESC


--23. Mes con mayor crecimiento de ventas respecto al mes anterior
--¿En qué mes se dio el mayor salto de ventas EV en cada país?

WITH ventas_mensuales as (
SELECT dc.country_name,dd.year,dd.month, SUM(mm.units_sold) as 'total_ventas'
FROM dim_country1 as dc
INNER JOIN
	ev_market_master1 as mm ON dc.country_id = mm.country_id
INNER JOIN 
	dim_date as dd ON mm.date_id = dd.date_id
GROUP BY  dc.country_name,dd.year,dd.month

),

con_lag as (
SELECT *, 
LAG(total_ventas) OVER (PARTITION BY country_name ORDER BY year,month ) as 'total_anterior',
total_ventas - LAG(total_ventas) OVER (PARTITION BY country_name ORDER BY year,month ) as 'diferencia'
FROM ventas_mensuales
),

ranking as (

SELECT 
*,
RANK() OVER (PARTITION BY country_name ORDER BY diferencia DESC) as 'ranking_global'
FROM con_lag
WHERE diferencia IS NOT NULL
)

SELECT country_name,year,month,total_ventas,total_anterior,diferencia as 'diferencia_ventas', ranking_global FROM ranking 
WHERE ranking_global = 1
ORDER BY diferencia_ventas DESC

--24. Top keyword por país que más creció en el último año vs el anterior
--¿Qué término EV ganó más interés en búsquedas en el último año?

WITH avg_score as (

SELECT dc.country_name,dk.keyword, dd.year, 
ROUND(AVG(tm.trend_score),2) as 'promedio_score'
FROM ev_trends_monthly1 as tm
INNER JOIN 
	dim_date as dd ON tm.date_id = dd.date_id
INNER JOIN 
dim_keyword as dk ON dk.keyword_id = tm.keyword_id
INNER JOIN	
	dim_country1 as dc ON tm.country_id= dc.country_id
GROUP BY dc.country_name,dk.keyword, dd.year
),

avg_lag as (
SELECT *, 
LAG(promedio_score) OVER (PARTITION BY country_name, keyword ORDER BY year) as 'promedio_anterior',
promedio_score - LAG(promedio_score) OVER (PARTITION BY country_name, keyword  ORDER BY year) 'crecimiento'
FROM avg_score

),

rank_avg as (
SELECT *,
RANK () OVER (PARTITION BY country_name ORDER BY crecimiento DESC) as 'rank_global'
FROM avg_lag
WHERE crecimiento IS NOT NULL
)
SELECT country_name,keyword,year,promedio_score,promedio_anterior, crecimiento FROM rank_avg
WHERE rank_global = 1
ORDER BY crecimiento DESC

 --25. Ranking de países por ventas EV dentro de cada año
--¿Qué posición ocupa cada país en ventas EV dentro de su año?

WITH ventas_anuales as (

SELECT dc.country_name, dd.year , SUM(mm.units_sold) as 'ventas_totales' FROM ev_market_master1 as mm 
INNER JOIN 
	dim_country1 as dc ON mm.country_id = dc.country_id
INNER JOIN	
	dim_date as dd ON mm.date_id = dd.date_id
GROUP BY dc.country_name, dd.year

),

ranking as (
SELECT *,
DENSE_RANK() OVER (PARTITION BY year ORDER BY ventas_totales DESC) as 'ranking_actual'
FROM ventas_anuales
)

SELECT country_name, year, ventas_totales, ranking_actual, 
LAG(ranking_actual) OVER (PARTITION BY country_name ORDER BY year) as 'ranking_anterior',
LAG(ranking_actual) OVER (PARTITION BY country_name ORDER BY year) - ranking_actual as 'mejora'
FROM ranking
ORDER BY year,ranking_actual 

-- 26. ¿Cuánto creció cada país año a año, y ese crecimiento fue bueno, estable o negativo?
WITH annual_sales AS(
SELECT dc.country_name,dd.year,
SUM(mm.units_sold) as 'total_sales'
FROM dim_country1 as dc
INNER JOIN
	ev_market_master1 as mm ON dc.country_id = mm.country_id
INNER JOIN 
	dim_date as dd ON mm.date_id = dd.date_id
GROUP BY dc.country_name,dd.year

),

yoy as ( SELECT
        country_name,
        year,
        total_sales,
        LAG(total_sales) OVER (PARTITION BY country_name ORDER BY year) AS prev_year,
        ROUND(
            (total_sales - LAG(total_sales) OVER (PARTITION BY country_name ORDER BY year)) * 100.0 /
            NULLIF(LAG(total_sales) OVER (PARTITION BY country_name ORDER BY year), 0),
        2) AS yoy_pct
    FROM annual_sales
)

SELECT country_name,year,total_sales,prev_year,yoy_pct,
CASE 
WHEN yoy_pct IS NULL THEN 'sin año anterior'
WHEN yoy_pct >= 30 THEN 'bueno'
WHEN yoy_pct >=5 THEN 'estable'
WHEN  yoy_pct >=-5 THEN 'estable'
ELSE 'caida'
END AS growth_label
FROM yoy


SELECT country_name,SUM(mm.units_sold) as 'total_ventas'
FROM dim_country1 as dc
INNER JOIN  
 ev_market_master1 as mm ON dc.country_id = mm.country_id
GROUP BY  country_name
ORDER BY  Total_ventas DESC

SELECT TOP 3 dd.year,dd.month,SUM(mm.units_sold) as 'total_ventas' FROM ev_market_master1 as mm
INNER JOIN 
	dim_date as dd ON mm.date_id = dd.date_id
GROUP BY dd.year,dd.month
ORDER BY total_ventas DESC