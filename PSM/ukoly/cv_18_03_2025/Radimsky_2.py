import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score

# Načtení datasetu
df = pd.read_csv("winequality-red.csv", sep=";")
print(df.info())
print(df.describe())

# Předzpracování dat
# Zpracování chybějících hodnot (např. odstranění nebo imputace)
df = df.dropna()

# Rozdělení na vstupní a výstupní proměnné
X = df.drop("quality", axis=1)
y = df["quality"]

# Normalizace numerických atributů
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Rozdělení na trénovací a testovací sadu (70:30)
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.3, random_state=42)

# Trénování modelů
models = {
    "Decision Tree": DecisionTreeRegressor(),
    "Random Forest": RandomForestRegressor()
}

for name, model in models.items():
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)

    print(f"\n{name}:")
    print(f"MSE: {mean_squared_error(y_test, y_pred):.4f}")
    print(f"RMSE: {np.sqrt(mean_squared_error(y_test, y_pred)):.4f}")
    print(f"R2 Score: {r2_score(y_test, y_pred):.4f}")

"""
Dle vypočítaných metrik můžeme porhlásit, že model Random Forest dosahuje lepších výsledků než model Decision Tree.
"""
