import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score


# Načtení dat
simplreg = pd.read_csv("simplreg.txt", delim_whitespace=True, skiprows=1, names=["X", "Y"])
fruitohms = pd.read_csv("fruitohms.txt", delim_whitespace=True, skiprows=1, names=["ID", "Juice", "Ohms"])

# Vytvoření figure s dvěma subploty
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# První graf: Y = F(X)
axes[0].scatter(simplreg["X"], simplreg["Y"], color="blue", alpha=0.7)
axes[0].set_xlabel("X")
axes[0].set_ylabel("Y")
axes[0].set_title("Závislost Y = F(X)")

# Druhý graf: Juice = F(Ohms)
axes[1].scatter(fruitohms["Ohms"], fruitohms["Juice"], color="green", alpha=0.7)
axes[1].set_xlabel("Ohms")
axes[1].set_ylabel("Juice")
axes[1].set_title("Závislost Juice = F(Ohms)")

# Uložení grafů do souboru
plt.tight_layout()
plt.savefig("scatter_plots.png", dpi=300)

# Zobrazení grafů
plt.show()


# Připravíme dvojice (X, Y) pro regresi
datasets = {
    "simplreg": (simplreg["X"].values.reshape(-1, 1), simplreg["Y"].values),
    "fruitohms": (fruitohms["Ohms"].values.reshape(-1, 1), fruitohms["Juice"].values)
}

# Definujeme rozsah stupňů polynomu
degrees = list(range(1, 11))

# Uchování metrik pro každý dataset
metrics = {
    "simplreg": {"MSE": [], "RMSE": [], "MAE": [], "R2": []},
    "fruitohms": {"MSE": [], "RMSE": [], "MAE": [], "R2": []}
}

# Regresní analýza
for name, (X, y) in datasets.items():
    for d in degrees:
        poly = PolynomialFeatures(degree=d)
        X_poly = poly.fit_transform(X)

        model = LinearRegression()
        model.fit(X_poly, y)
        y_pred = model.predict(X_poly)

        # Výpočet metrik
        mse = mean_squared_error(y, y_pred)
        rmse = np.sqrt(mse)
        mae = mean_absolute_error(y, y_pred)
        r2 = r2_score(y, y_pred)

        # Uložení metrik
        metrics[name]["MSE"].append(mse)
        metrics[name]["RMSE"].append(rmse)
        metrics[name]["MAE"].append(mae)
        metrics[name]["R2"].append(r2)

# Vykreslení grafů kvality modelů
datasets = ["simplreg", "fruitohms"]
metrics_names = ["MSE", "RMSE", "MAE", "R2"]

for i, dataset in enumerate(datasets):
    fig, axes = plt.subplots(2, 2, figsize=(16, 4))  # 2 řádky, 2 sloupce

    for j, metric in enumerate(metrics_names):
        axes[j // 2, j % 2].plot(degrees, metrics[dataset][metric], marker="o")
        axes[j // 2, j % 2].set_xlabel("Stupeň polynomu")
        axes[j // 2, j % 2].set_ylabel(metric)
        axes[j // 2, j % 2].set_title(f"{metric} pro {dataset}")

    plt.tight_layout()
    plt.savefig(f"{dataset}_metrics.png", dpi=300)
    plt.show()

X_simplreg, Y_simplreg = simplreg["X"].values, simplreg["Y"].values
X_fruitohms, Y_fruitohms = fruitohms["Ohms"].values, fruitohms["Juice"].values

datasets = {
    "simplreg": (X_simplreg, Y_simplreg),
    "fruitohms": (X_fruitohms, Y_fruitohms)
}

# Vybrání nejlepšího modelu pro každý dataset podle metrik z předchozího kroku a vlastního uvážení
best_degrees = {
    "simplreg": 2,
    "fruitohms": 3
}

fig, axes = plt.subplots(1, 2, figsize=(12, 5))  # 1 řádek, 2 sloupce

for i, (dataset, (X, Y)) in enumerate(datasets.items()):
    ax = axes[i]

    # Scatter plot
    ax.scatter(X, Y, color="blue", label="Data")

    # Lineární regrese
    lin_reg = LinearRegression().fit(X.reshape(-1, 1), Y)
    X_range = np.linspace(X.min(), X.max(), 100).reshape(-1, 1)
    Y_lin_pred = lin_reg.predict(X_range)
    ax.plot(X_range, Y_lin_pred, color="red", label="Lineární regrese")

    # Polynomiální regrese (best_degree)
    poly_coeffs = np.polyfit(X, Y, best_degrees[dataset])
    Y_poly_pred = np.polyval(poly_coeffs, X_range)
    ax.plot(X_range, Y_poly_pred, color="green", label=f"Polynom {best_degrees[dataset]}. stupně")

    # Nastavení grafu
    ax.set_xlabel("X")
    ax.set_ylabel("Y")
    ax.set_title(f"Regrese pro {dataset}")
    ax.legend()

plt.tight_layout()
plt.savefig("regression_results.png", dpi=300)
plt.show()


