import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.metrics import root_mean_squared_error, r2_score
from sqlalchemy import create_engine

# Připojení k databázi
engine = create_engine('postgresql://postgres:postgres@localhost:5432/ODM_db')

# Získání vzorku dat
query = """
SELECT 
    e.event_type,
    p.brand,
    p.category_code,
    e.price
FROM events_fact e
JOIN product_dim p ON e.product_id = p.product_id
WHERE e.price IS NOT NULL AND p.brand IS NOT NULL AND p.category_code IS NOT NULL
LIMIT 10000
"""
df = pd.read_sql(query, engine)

# Vstupní a cílové proměnné
X = df[['event_type', 'brand', 'category_code']]
y = df['price']

# One-hot encoding pro kategorické proměnné
preprocessor = ColumnTransformer([
    ('encoder', OneHotEncoder(handle_unknown='ignore'), ['event_type', 'brand', 'category_code'])
])

# Model: lineární regrese
model = Pipeline(steps=[
    ('preprocessor', preprocessor),
    ('regressor', LinearRegression())
])

# Trénink/test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Trénování modelu
model.fit(X_train, y_train)

# Předpověď
y_pred = model.predict(X_test)

# Vyhodnocení
print("R² score:", r2_score(y_test, y_pred))
print("Root Mean Squared Error:", root_mean_squared_error(y_test, y_pred))
