import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
from sklearn.model_selection import train_test_split

# Načtení datasetu
df = pd.read_csv("manufacturing.csv")

# Definujeme vstupy (X) a výstup (Y)
features = [
    "Temperature (°C)",
    "Pressure (kPa)",
    "Temperature x Pressure",
    "Material Fusion Metric",
    "Material Transformation Metric",
]
target = "Quality Rating"

# Prozkoumáme vztahy mezi proměnnými pomocí scatter plotů
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
axes = axes.ravel()

for i, feature in enumerate(features):
    axes[i].scatter(df[feature], df[target], alpha=0.5)
    axes[i].set_xlabel(feature)
    axes[i].set_ylabel(target)
    axes[i].set_title(f"{feature} vs. {target}")

plt.tight_layout()
plt.savefig("scatter_plots.png", dpi=300)
plt.show()

# Polynomiální regrese pro každou proměnnou
max_degree = 9
metrics = {feature: {"MSE": [], "RMSE": [], "R2": []} for feature in features}

fig, axes = plt.subplots(2, 3, figsize=(15, 10))
axes = axes.ravel()

for i, feature in enumerate(features):
    X = df[[feature]].values
    y = df[target].values

    # Split data into training and testing sets
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

    for degree in range(1, max_degree + 1):
        poly = PolynomialFeatures(degree=degree)
        X_poly_train = poly.fit_transform(X_train)
        X_poly_test = poly.transform(X_test)

        poly_reg = LinearRegression()
        poly_reg.fit(X_poly_train, y_train)

        y_pred = poly_reg.predict(X_poly_test)

        mse = mean_squared_error(y_test, y_pred)
        rmse = np.sqrt(mse)
        r2 = r2_score(y_test, y_pred)

        metrics[feature]["MSE"].append(mse)
        metrics[feature]["RMSE"].append(rmse)
        metrics[feature]["R2"].append(r2)

    # Vykreslíme graf metrik vs. stupeň polynomu
    axes[i].plot(range(1, max_degree + 1), metrics[feature]["MSE"], label="MSE", marker="o")
    axes[i].plot(range(1, max_degree + 1), metrics[feature]["RMSE"], label="RMSE", marker="s")
    axes[i].plot(range(1, max_degree + 1), metrics[feature]["R2"], label="R²", marker="^")
    axes[i].set_xlabel("Stupeň polynomu")
    axes[i].set_ylabel("Chyba")
    axes[i].set_title(f"Chyby pro {feature}")
    axes[i].legend()

plt.tight_layout()
plt.savefig("error_vs_degree.png", dpi=300)
plt.show()

# Výběr nejlepšího modelu pro každou proměnnou
# Volím podle grafů z předchozího kroku a vlastního uvážení
best_degrees = [4, 1, 1, 3, 4]

# Uložíme nejlepší modely do PNG souborů
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
axes = axes.ravel()

for i, feature in enumerate(features):
    best_degree = best_degrees[i]
    X = df[[feature]].values
    y = df[target].values

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

    poly = PolynomialFeatures(degree=best_degree)
    X_poly_train = poly.fit_transform(X_train)
    X_poly_test = poly.transform(X_test)

    poly_reg = LinearRegression()
    poly_reg.fit(X_poly_train, y_train)

    y_pred = poly_reg.predict(X_poly_test)

    # Seřadíme X_test a y_pred podle X_test
    sorted_index = np.argsort(X_test, axis=0).flatten()  # Seřazení indexů
    X_sorted = X_test[sorted_index]  # Seřazené hodnoty X
    y_pred_sorted = y_pred[sorted_index]  # Predikce seřazené podle X

    # Vykreslení
    axes[i].scatter(X_test, y_test, alpha=0.5, label="Data")
    axes[i].plot(X_sorted, y_pred_sorted, color="red", label=f"Polynom {best_degree}. stupně")
    axes[i].set_xlabel(feature)
    axes[i].set_ylabel(target)
    axes[i].set_title(f"Regrese pro {feature}")
    axes[i].legend()


plt.tight_layout()
plt.savefig("best_models.png", dpi=300)
plt.show()
