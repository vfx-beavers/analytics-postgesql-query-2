import pandas as pd


# Загрузка данных из файлов csv
folder = 'E:/DE/Auchan/bin/' #локальная папка. для проверки заменить
sales = (folder + 'test_sales.csv')
promo_fact = (folder + 'test_promo_fact1.csv')
promo_lookup = (folder + 'test_promo_lookup.csv')

frame = pd.DataFrame()
df_sales = pd.read_csv(sales, on_bad_lines='warn', sep = ";", index_col=None, header=0, dtype=str) #, engine='python' 
df_promo_fact = pd.read_csv(promo_fact, on_bad_lines='warn', sep = ";", index_col=None, header=0, dtype=str)
df_promo_lookup = pd.read_csv(promo_lookup, on_bad_lines='warn', sep = ";", index_col=None, header=0, dtype=str)

# замена разделителя
df_promo_fact['SALE_PRICE'] = df_promo_fact['SALE_PRICE'].str.replace(',','.')
df_sales['F_SALE_AMT'] = df_sales['F_SALE_AMT'].str.replace(',','.')
df_sales['F_SALE_AMT_NOVAT'] = df_sales['F_SALE_AMT_NOVAT'].str.replace(',','.')

# Преобразование столбцов типов данных и пустых значений df_sales 
df_sales['F_SALE_DT'] = pd.to_datetime(df_sales['F_SALE_DT'], errors='coerce')
df_sales['F_SALE_AMT'] = df_sales['F_SALE_AMT'].astype('float32')#.fillna(0)
df_sales['F_SALE_AMT_NOVAT'] = df_sales['F_SALE_AMT_NOVAT'].astype('float32')#.fillna(0)
df_sales['F_SALE_QTY'] = pd.to_numeric(df_sales['F_SALE_QTY'], errors='coerce').fillna(0).astype('int64')
df_sales['F_SALE_UNIT_QTY'] = pd.to_numeric(df_sales['F_SALE_UNIT_QTY'], errors='coerce').fillna(0).astype('int64')
df_sales.update(df_sales[['F_SALE_AMT_NOVAT','F_SALE_AMT']].fillna(0))

# Преобразование столбцов типов данных и пустых значений df_promo_fact
df_promo_fact['START_DT'] = pd.to_datetime(df_promo_fact['START_DT'], errors='coerce')
df_promo_fact['END_DT'] = pd.to_datetime(df_promo_fact['END_DT'], errors='coerce')
df_promo_fact["SALE_PRICE"] = df_promo_fact['SALE_PRICE'].astype('float32')#.fillna(0)
df_promo_fact['PROMO_ORD_CONF_QTY'] = pd.to_numeric(df_promo_fact['PROMO_ORD_CONF_QTY'], errors='coerce').fillna(0).astype('int64')

# проверка df
#print(df_sales)
#print(df_promo_fact)
#print(df_promo_lookup)

# проверка типов df
#print(df_sales.dtypes)
#print(df_promo_fact.dtypes)
#print(df_promo_lookup.dtypes)

# экспорт обновлённого df в csv для импорта в бд
df_sales.to_csv('E:/DE/Auchan/OUT/df_sales.csv', index=False, sep=';', encoding='utf-8-sig')
df_promo_fact.to_csv('E:/DE/Auchan/OUT/df_promo_fact.csv', index=False, sep=';', encoding='utf-8-sig')
df_promo_lookup.to_csv('E:/DE/Auchan/OUT/df_promo_lookup.csv', index=False, sep=';', encoding='utf-8-sig')

print('экспортировано в csv')