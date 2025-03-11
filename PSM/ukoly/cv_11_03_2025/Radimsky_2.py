import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.model_selection import train_test_split
import seaborn as sns
from sklearn.preprocessing import StandardScaler
import statsmodels.api as sm

# Načtení dat
df = pd.read_csv("house_data.csv")

pd.set_option('display.max_columns', None)
print(df.info())
print(df.describe())

plt.figure(figsize=(12, 8))
sns.heatmap(df.corr(), annot=True, cmap="coolwarm", fmt=".2f")
plt.show()

# Funcke pro vytvoření modelu mnohonásobné lineární regrese
def multiple_linear_regression(df):
    X = df.drop(columns=["MEDV"])  # Cílová proměnná MEDV
    y = df["MEDV"]

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

    model = LinearRegression()
    model.fit(X_train, y_train)

    y_pred = model.predict(X_test)

    X_train_const = sm.add_constant(X_train)
    model_stat = sm.OLS(y_train, X_train_const).fit()
    print(model_stat.summary())

    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    r2 = r2_score(y_test, y_pred)

    return rmse, r2

metrics = pd.DataFrame(columns=["Model", "RMSE", "R²"])

# Model 1: Všechny proměnné bez normalizace
rmse, r2 = multiple_linear_regression(df)
metrics = pd.concat([metrics, pd.DataFrame([{"Model": "All Features", "RMSE": rmse, "R²": r2}])], ignore_index=True)

# Model 2: Všechny proměnné s normalizací
scaler = StandardScaler()
df_scaled = pd.DataFrame(scaler.fit_transform(df), columns=df.columns)
rmse, r2 = multiple_linear_regression(df_scaled)
metrics = pd.concat([metrics, pd.DataFrame([{"Model": "All Features Scaled", "RMSE": rmse, "R²": r2}])], ignore_index=True)

# Model 3: Odstranění nevýznamných proměnných (p-value > 0.05)
df_scaled = df_scaled.drop(columns=["INDUS", "AGE","TAX"])
rmse, r2 = multiple_linear_regression(df_scaled)
metrics = pd.concat([metrics, pd.DataFrame([{"Model": "Significant Features", "RMSE": rmse, "R²": r2}])], ignore_index=True)

# Model 4: Odstranění nových nevýznamných proměnných (p-value > 0.05)
df_scaled = df_scaled.drop(columns=["ZN"])
rmse, r2 = multiple_linear_regression(df_scaled)
metrics = pd.concat([metrics, pd.DataFrame([{"Model": "Significant Features 2", "RMSE": rmse, "R²": r2}])], ignore_index=True)
    # V tomto modelu jsou všechny proměnné statisticky významné


print(metrics)

