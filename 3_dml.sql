--загрузка периодов из views в общую таблицу main_table

-- N период 09.02.2023-23.02.2023
INSERT INTO main_table (period_name, OBJECT_BK, SEGMENT_BK, PRODUCT_CODE, PROMO_PERIOD_TYPE_DESCRIPTION, PROMO_ACTION_TYPE_NAME, PLACE_TYPE, SALE_PRICE, discount_perc, PROMO_ORD_CONF_QTY)
SELECT period_name, OBJECT_BK, SEGMENT_BK, PRODUCT_CODE, PROMO_PERIOD_TYPE_DESCRIPTION, PROMO_ACTION_TYPE_NAME, PLACE_TYPE, SALE_PRICE, discount_perc, PROMO_ORD_CONF_QTY 
FROM view_period_N;

-- 7d период 02.02.2023-08.02.2023
INSERT INTO main_table (period_name, OBJECT_BK, PRODUCT_CODE, sale_price_avg_7d, sale_qty_7d, sale_price_avg_last_7d)
SELECT period_name, OBJECT_BK, PRODUCT_CODE, sale_price_avg_7d, sale_qty_7d, sale_price_avg_last_7d 
from view_period_7d_before;

--N-1 период 29.12.2022-11.01.2023
INSERT INTO main_table (period_name, OBJECT_BK, SEGMENT_BK, PRODUCT_CODE, promo_action_type_name_n1, PLACE_TYPE_n1, avg_qty_per_day_wo_0_n1, avg_qty_per_day_n1, days_wo_sales_n1, sale_price_avg_n1, PROMO_ORD_CONF_QTY)
select period_name, OBJECT_BK, SEGMENT_BK, PRODUCT_CODE, promo_action_type_name_n1, PLACE_TYPE_n1, avg_qty_per_day_wo_0_n1, avg_qty_per_day_n1, days_wo_sales_n1, sale_price_avg_n1, PROMO_ORD_CONF_QTY 
from view_period_N1;

--N-2 период 15.12.2022-28.12.2022
INSERT INTO main_table (period_name, OBJECT_BK, SEGMENT_BK, PRODUCT_CODE, promo_action_type_name_n2, place_type_n2, avg_qty_per_day_n2_wo_0, sale_price_avg_n2, PROMO_ORD_CONF_QTY)
select period_name, OBJECT_BK, SEGMENT_BK, PRODUCT_CODE, promo_action_type_name_n2, place_type_n2, avg_qty_per_day_n2_wo_0, sale_price_avg_n2, PROMO_ORD_CONF_QTY  
from view_n2_period;

--экспорт промежуточного файла в df для переименования столбцов сводной таблицы
--COPY main_table TO '/tmp/tmp_main_table.csv' DELIMITER ';' CSV HEADER;

 
