import pandas as pd
import sqlalchemy
import psycopg2
import openpyxl
from sqlalchemy import create_engine
from sqlalchemy.engine import URL


# загрузка сводной таблицы main_table из бд (локальный докер) в df
engine = create_engine('postgresql+psycopg2://pguser:pgpwd@localhost:15432/de')
con = engine.connect()

df = pd.read_sql('SELECT * FROM main_table', con, index_col=None)
#print(df)

# переименование столбцов
df.rename(columns={'period_name': 'Период действия скидки', 
                   'object_bk': 'Магазин',
                   'segment_bk': 'Сегмент',
                   'product_code': 'Артикул',
                   'promo_period_type_description': 'Период промоакции',
                   'promo_action_type_name': 'Тип Промо',
                   'place_type': 'Тип промо места',
                   'sale_price': 'Цена промо с НДС',
                   'discount_perc': '% Скидки / % кэшбэка',
                   'sale_price_avg_7d': 'Средняя цена продажи с НДС в период до промо шт/кг',
                   'sale_qty_7d': 'Продажи за последние 7 дней шт/кг',
                   'sale_price_avg_last_7d': 'Средняя цена продажи за последние 7 дней',
                   'promo_action_type_name_n1': 'ТИП промо N-1',
                   'place_type_n1': 'ТИП промо места N-1',
                   'avg_qty_per_day_wo_0_n1': 'Средние продажи в день за период N-1 промо (без учета дней без продаж) в шт/кг',
                   'avg_qty_per_day_n1': 'Средние продажи в день за период N-1 промо  в шт/кг.',
                   'days_wo_sales_n1': 'Кол-во дней без продаж',
                   'sale_price_avg_n1': 'Средня цена продажи за период N-1 промо',
                   'promo_action_type_name_n2': 'ТИП промо N-2',
                   'place_type_n2': 'ТИП промо места N-2',
                   'avg_qty_per_day_n2_wo_0': 'Средние продажи в день за период N-2 промо (без учета дней без продаж) в шт/кг.',
                   'sale_price_avg_n2': 'Средня цена продажи за период N-2 промо ',
                   'promo_ord_conf_qty': 'Подтвержденные количества магазина'
                   }, inplace=True)

print(df)

# экспорт в exel
df.to_excel("E:\DE\Auchan\OUT\out_main_table.xlsx", index= False )
#df_sales.to_csv('E:/DE/Auchan/OUT/df_sales.csv', index=False, sep=';', encoding='utf-8-sig')

print('экспортировано в xlsx')