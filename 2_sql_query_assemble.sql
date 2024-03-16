--  сводный запрос

DROP VIEW IF EXISTS view_period_N CASCADE;
DROP VIEW IF EXISTS view_period_7d_before CASCADE;
DROP VIEW IF EXISTS view_n1_days_wo_sales CASCADE;
DROP VIEW IF EXISTS view_avg_qty_per_day_n1_wo_0 CASCADE;
DROP VIEW IF EXISTS view_avg_qty_per_day_n1 CASCADE;
DROP VIEW IF EXISTS view_sale_price_avg_n1 CASCADE;
DROP VIEW IF EXISTS view_period_N1 CASCADE;
DROP VIEW IF EXISTS view_n2_avg_qty_per_day_wo_0 CASCADE;
DROP VIEW IF EXISTS view_n2_sale_price_avg CASCADE;
DROP VIEW IF EXISTS view_n2_period CASCADE;

--7 дневный период 02.02.2023-08.02.2023 перед промо------------------------
CREATE VIEW view_period_7d_before AS
SELECT 
  '02.02.2023-08.02.2023' AS period_name,
  OBJECT_BK,
  PRODUCT_CODE,
  round(avg(F_SALE_AMT / NULLIF(F_SALE_UNIT_QTY,0)),0) as sale_price_avg_7d,
  sum(F_SALE_UNIT_QTY) as sale_qty_7d,
  round(avg(F_SALE_AMT / NULLIF(F_SALE_UNIT_QTY,0)),0) as sale_price_avg_last_7d
FROM stg_sales 
WHERE F_SALE_DT BETWEEN '2023-02-02' AND '2023-02-08'-- and PRODUCT_CODE = '765263'
GROUP by OBJECT_BK, PRODUCT_CODE
;
SELECT * FROM view_period_7d_before;


--N период 09.02.2023-23.02.2023--------------------------------------------
CREATE VIEW view_period_N AS
SELECT 
  '09.02.2023-23.02.2023' AS period_name,
  pf.OBJECT_BK,
  pf.SEGMENT_BK,
  pf.PRODUCT_CODE,
  pl.PROMO_PERIOD_TYPE_DESCRIPTION,
  pl.PROMO_ACTION_TYPE_NAME,
  pl.PLACE_TYPE,
  pf.SALE_PRICE,
  round(((wk.sale_price_avg_7d - pf.SALE_PRICE) / pf.SALE_PRICE * 100), 2) AS discount_perc,  -- :-/
  pf.PROMO_ORD_CONF_QTY
FROM stg_promo_fact1 as pf
JOIN stg_promo_lookup as pl ON pf.PROMO_ACTION_HK = pl.PROMO_ACTION_HK
join view_period_7d_before as wk on wk.OBJECT_BK = pf.OBJECT_BK AND wk.PRODUCT_CODE = pf.PRODUCT_CODE
WHERE pf.START_DT = '2023-02-09' AND pf.END_DT = '2023-02-23'
;
SELECT * FROM view_period_N;
-----------------------------------------------------------------------------


--N-1 период 29.12.2022-11.01.2023-------------------------------------------
--n1_days_wo_sales
CREATE VIEW view_n1_days_wo_sales AS
select PRODUCT_CODE,
       dd.n1_days_w_sales, 
       dd.n1_days_all,
       (dd.n1_days_all - dd.n1_days_w_sales) as n1_days_wo_sales
       from (
select PRODUCT_CODE, (select count (*) as n1_days_all from (select generate_series('2022-12-29'::date,'2023-01-11'::date, '1 day')) as a ) as n1_days_all, 
       count (*) as n1_days_w_sales
from 
  (select F_SALE_DT, PRODUCT_CODE, count(F_SALE_DT) 
  from stg_sales 
  WHERE F_SALE_DT between '2022-12-29' and '2023-01-11' 
  GROUP BY F_SALE_DT, PRODUCT_CODE ) as c 
GROUP BY PRODUCT_CODE) as dd
;
SELECT * FROM view_n1_days_wo_sales;


CREATE VIEW view_avg_qty_per_day_n1_wo_0 AS
SELECT OBJECT_BK, PRODUCT_CODE, round(avg(F_SALE_UNIT_QTY),2) AS avg_qty_per_day_n1_wo_0
FROM stg_sales
WHERE F_SALE_DT BETWEEN '2022-12-29' AND '2023-01-11' 
--and PRODUCT_CODE = '139109' --для проверки. 
GROUP BY OBJECT_BK, PRODUCT_CODE
;
SELECT * FROM view_avg_qty_per_day_n1_wo_0;


CREATE VIEW view_avg_qty_per_day_n1 AS
SELECT OBJECT_BK, PRODUCT_CODE, round(avg(F_SALE_UNIT_QTY) / (select count (*) from (select generate_series('2022-12-29'::date,'2023-01-11'::date, '1 day')) as a ) ,2) AS avg_qty_per_day_n1 --14
FROM stg_sales
WHERE F_SALE_DT BETWEEN '2022-12-29' AND '2023-01-11' 
--and PRODUCT_CODE = '139109' --для проверки.
GROUP BY OBJECT_BK, PRODUCT_CODE
;
SELECT * FROM view_avg_qty_per_day_n1;

CREATE VIEW view_sale_price_avg_n1 AS
SELECT OBJECT_BK, PRODUCT_CODE, round(avg(F_SALE_AMT),2) as sale_price_avg_n1
FROM stg_sales
where F_SALE_DT BETWEEN '2022-12-29' AND '2023-01-11'
--and PRODUCT_CODE = '139109' --для проверки. 
GROUP BY OBJECT_BK, PRODUCT_CODE
;
SELECT * FROM view_sale_price_avg_n1;


CREATE VIEW view_period_N1 AS
SELECT 
  '29.12.2022 - 11.01.2023' AS period_name,
  pf.OBJECT_BK, --::numeric убрать нули спереди
  pf.SEGMENT_BK,
  pf.PRODUCT_CODE,
  pl.PROMO_ACTION_TYPE_NAME as promo_action_type_name_n1,
  pl.PLACE_TYPE as PLACE_TYPE_n1,
  avgq.avg_qty_per_day_n1_wo_0 as avg_qty_per_day_wo_0_n1, 
  avgqq.avg_qty_per_day_n1 as avg_qty_per_day_n1,  
  wo.n1_days_wo_sales as days_wo_sales_n1, 
  savg.sale_price_avg_n1,
  pf.PROMO_ORD_CONF_QTY
FROM stg_promo_fact1 as pf
join stg_sales as s on s.OBJECT_BK = pf.OBJECT_BK AND s.PRODUCT_CODE = pf.PRODUCT_CODE
JOIN stg_promo_lookup as pl ON pf.PROMO_ACTION_HK = pl.PROMO_ACTION_HK
join view_n1_days_wo_sales as wo on wo.PRODUCT_CODE = pf.PRODUCT_CODE
join view_avg_qty_per_day_n1 as avgqq on avgqq.OBJECT_BK = pf.OBJECT_BK AND avgqq.PRODUCT_CODE = pf.PRODUCT_CODE
join view_avg_qty_per_day_n1_wo_0 as avgq on avgq.OBJECT_BK = pf.OBJECT_BK AND avgq.PRODUCT_CODE = pf.PRODUCT_CODE
join view_sale_price_avg_n1 as savg on savg.OBJECT_BK = pf.OBJECT_BK AND savg.PRODUCT_CODE = pf.PRODUCT_CODE
WHERE pf.START_DT = '2022-12-29' AND pf.END_DT = '2023-01-11' --and s.PRODUCT_CODE = '139109' 
GROUP by pf.OBJECT_BK, pf.PRODUCT_CODE, pf.SEGMENT_BK, pl.PROMO_ACTION_TYPE_NAME, pl.PLACE_TYPE, 
         wo.n1_days_wo_sales, avgq.avg_qty_per_day_n1_wo_0, savg.sale_price_avg_n1, avgqq.avg_qty_per_day_n1, 
         pf.PROMO_ORD_CONF_QTY--мб н
;
SELECT * FROM view_period_N1;
---------------------------------------------------------------------------------


-- period_N-2--------------------------------------------------------------------
-- N-2. Средние продажи в день за период N-2 промо (без учета дней без продаж) в шт/кг.
CREATE VIEW view_n2_avg_qty_per_day_wo_0 AS
SELECT OBJECT_BK, PRODUCT_CODE, round(avg(F_SALE_UNIT_QTY),2) AS avg_qty_per_day_n2_wo_0
FROM stg_sales
WHERE F_SALE_DT BETWEEN '2022-12-15' AND '2022-12-28' 
--and PRODUCT_CODE = '171609' --для проверки. 
GROUP BY OBJECT_BK, PRODUCT_CODE
;
SELECT * FROM view_n2_avg_qty_per_day_wo_0;

-- N-2.  Средня цена продажи за период N-2 промо 
CREATE VIEW view_n2_sale_price_avg AS
SELECT OBJECT_BK, PRODUCT_CODE, round(avg(F_SALE_AMT),2) as sale_price_avg_n2
FROM stg_sales
where F_SALE_DT BETWEEN '2022-12-15' AND '2022-12-28'
--and PRODUCT_CODE = '171609' --для проверки. 
GROUP BY OBJECT_BK, PRODUCT_CODE
;
SELECT * FROM view_n2_sale_price_avg;

CREATE VIEW view_n2_period AS
SELECT 
  '15.12.2022 - 28.12.2022' AS period_name,
  pf.OBJECT_BK, --::numeric
  pf.SEGMENT_BK,
  pf.PRODUCT_CODE,
  pl.PROMO_ACTION_TYPE_NAME as promo_action_type_name_n2,
  pl.PLACE_TYPE as place_type_n2,
  avgq.avg_qty_per_day_n2_wo_0, 
  savg.sale_price_avg_n2,
  pf.PROMO_ORD_CONF_QTY
FROM stg_promo_fact1 as pf
join stg_sales as s on s.OBJECT_BK = pf.OBJECT_BK AND s.PRODUCT_CODE = pf.PRODUCT_CODE
JOIN stg_promo_lookup as pl ON pf.PROMO_ACTION_HK = pl.PROMO_ACTION_HK
join view_n2_avg_qty_per_day_wo_0 as avgq on avgq.OBJECT_BK = pf.OBJECT_BK AND avgq.PRODUCT_CODE = pf.PRODUCT_CODE
join view_n2_sale_price_avg as savg on savg.OBJECT_BK = pf.OBJECT_BK AND savg.PRODUCT_CODE = pf.PRODUCT_CODE
WHERE pf.START_DT = '2022-12-15' AND pf.END_DT = '2022-12-28' --and s.PRODUCT_CODE = '171609' 
GROUP by pf.OBJECT_BK, pf.PRODUCT_CODE, pf.SEGMENT_BK, pl.PROMO_ACTION_TYPE_NAME, pl.PLACE_TYPE, avgq.avg_qty_per_day_n2_wo_0, savg.sale_price_avg_n2, pf.PROMO_ORD_CONF_QTY 
;
SELECT * FROM view_n2_period;
---------------------------------------------------------------------------------