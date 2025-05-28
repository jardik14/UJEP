import pandas as pd
from sklearn.cluster import KMeans
from sqlalchemy import create_engine
import matplotlib.pyplot as plt
import seaborn as sns

# Připojení k PostgreSQL
engine = create_engine('postgresql://postgres:postgres@localhost:5432/ODM_db')

# SQL dotaz – získání údajů o chování uživatelů
query = """
SELECT 
    user_id,
    COUNT(*) AS purchase_count,
    AVG(price) AS avg_price,
    COUNT(DISTINCT p.category_code) AS distinct_categories
FROM events_fact e
JOIN product_dim p ON e.product_id = p.product_id
WHERE event_type = 'purchase'
GROUP BY user_id
HAVING COUNT(*) > 2
"""

df = pd.read_sql(query, engine)

# Normalizace dat
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
X = scaler.fit_transform(df[['purchase_count', 'avg_price', 'distinct_categories']])

# Shlukování
kmeans = KMeans(n_clusters=3, random_state=42)
df['cluster'] = kmeans.fit_predict(X)

# Výstup do CSV nebo zobrazení
df.to_csv("user_clusters.csv", index=False)

# Vizualizace
sns.pairplot(df, hue="cluster", vars=['purchase_count', 'avg_price', 'distinct_categories'])
plt.show()
