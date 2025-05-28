import pandas as pd

# Cesta k původnímu souboru CSV
INPUT_FILE = "events.csv"

# Výstupní soubory
OUTPUT_EVENTS = "events_fact.csv"
OUTPUT_PRODUCTS = "product_dim.csv"
OUTPUT_DATES = "date_dim.csv"

# Načti dataset s ochranou před poškozením ID (stringy místo intů)
df = pd.read_csv(INPUT_FILE, 
                 dtype={
                     'user_id': str,
                     'product_id': str,
                     'category_id': str
                 })

# Smazání řádků kde je nějaký záznam prázdný
df = df.dropna(subset=['event_time', 'event_type', 'category_id', 'category_code', 'brand', 'price', 'user_id', 'user_session'])

# === DIMENZE PRODUKTŮ ===
product_dim = df[['product_id', 'category_id', 'category_code', 'brand']].drop_duplicates()
product_dim = product_dim.dropna(subset=['product_id'])
product_dim.to_csv(OUTPUT_PRODUCTS, index=False)

# === FAKTOVÁ TABULKA ===
events_fact = df[['event_time', 'event_type', 'product_id', 'user_id', 'user_session', 'price']]
events_fact.to_csv(OUTPUT_EVENTS, index=False)

# === DIMENZE ČASU ===
date_dim = df[['event_time']].drop_duplicates()
date_dim['event_time'] = pd.to_datetime(date_dim['event_time'], errors='coerce')
date_dim = date_dim.dropna(subset=['event_time'])

date_dim['day'] = date_dim['event_time'].dt.day
date_dim['month'] = date_dim['event_time'].dt.month
date_dim['year'] = date_dim['event_time'].dt.year
date_dim['hour'] = date_dim['event_time'].dt.hour

date_dim = date_dim.rename(columns={'event_time': 'full_date'})
date_dim = date_dim.reset_index(drop=True)
date_dim['date_id'] = date_dim.index + 1  # Primární klíč

date_dim.to_csv(OUTPUT_DATES, index=False)

print("✅ Soubor byl rozdělen na:")
print(f"- {OUTPUT_EVENTS}")
print(f"- {OUTPUT_PRODUCTS}")
print(f"- {OUTPUT_DATES}")
