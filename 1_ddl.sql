DROP DATABASE IF EXISTS de;
CREATE DATABASE de;

-- Очистка таблиц
DROP TABLE IF EXISTS stg_sales cascade;
DROP TABLE IF EXISTS stg_promo_fact1 cascade;
DROP TABLE IF EXISTS stg_promo_lookup cascade;
DROP TABLE IF EXISTS main_table cascade;
--truncate table stg_sales cascade;
--truncate table stg_promo_fact1 cascade;
--truncate table stg_promo_lookup cascade;
--truncate table main_table cascade;

-- Создание таблиц для импорта df_csv
CREATE table stg_promo_lookup (
    PROMO_ACTION_HK varchar(50) NULL,
	PROMO_ACTION_NAME varchar(100) NULL,
	PROMO_ACTION_TYPE_NAME varchar(20) NULL,
	PROMO_PERIOD_TYPE_DESCRIPTION varchar(20) NULL,
	PLACE_TYPE varchar(20) NULL
);

CREATE table stg_promo_fact1 (
    PROMO_ACTION_HK varchar(50) NULL,
	OBJECT_BK varchar(10) NULL,
	START_DT date NULL,
	END_DT date NULL,
	SEGMENT_BK varchar(10) null,
	PRODUCT_CODE varchar(20) null,
	SALE_PRICE numeric(14,2) null,
	PROMO_ORD_CONF_QTY int null
);


CREATE table stg_sales (
    OBJECT_BK varchar(10) NULL,
	PRODUCT_CODE varchar(20) NULL,
	F_SALE_DT date NULL,
	F_SALE_AMT numeric(14,2) null,
	F_SALE_AMT_NOVAT numeric(14,2) null,
	F_SALE_QTY int null,
	F_SALE_UNIT_QTY int null
);

-- Создание сводной таблицы 
CREATE TABLE main_table 
(
period_name varchar(50) NULL,
OBJECT_BK varchar(10) not NULL,
SEGMENT_BK varchar(10) null,
PRODUCT_CODE varchar(20) not null,
PROMO_PERIOD_TYPE_DESCRIPTION varchar(30),
PROMO_ACTION_TYPE_NAME varchar(30) NULL,
PLACE_TYPE varchar(30) NULL,
SALE_PRICE numeric(14,2) null,
discount_perc numeric(14,2) null,
sale_price_avg_7d numeric(14,2) null,
sale_qty_7d numeric(14,2) null,
sale_price_avg_last_7d numeric(14,2) null,
promo_action_type_name_n1 varchar(30) NULL, --!
PLACE_TYPE_n1 varchar(30) NULL,
avg_qty_per_day_wo_0_n1 numeric(14,2) null,
avg_qty_per_day_n1 numeric(14,2) null,
days_wo_sales_n1 int null,
sale_price_avg_n1 numeric(14,2) null,
promo_action_type_name_n2 varchar(30) NULL, --!
place_type_n2 varchar(30) NULL,             --!
avg_qty_per_day_n2_wo_0 numeric(14,2) null, 
sale_price_avg_n2 numeric(14,2) null,
PROMO_ORD_CONF_QTY int null
);

-- Заливка экспортированных csv в postgres из локальной папки на машине с БД
COPY stg_promo_fact1 FROM '/home/df_promo_fact.csv' WITH DELIMITER ';' CSV HEADER;
COPY stg_promo_lookup FROM '/home/df_promo_lookup.csv' WITH DELIMITER ';' CSV HEADER;
COPY stg_sales FROM '/home/df_sales.csv' WITH DELIMITER ';' CSV HEADER;

