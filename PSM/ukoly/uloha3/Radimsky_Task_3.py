import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
from sklearn.model_selection import train_test_split
from scipy.optimize import curve_fit

# Načtení dat
df_BoxBOD = pd.read_csv("BoxBOD.txt", delim_whitespace=True, skiprows=1, names=["x", "y"])
df_misrala = pd.read_csv("misrala.txt", delim_whitespace=True, skiprows=1, names=["ID", "x", "y"])

x_misrala = df_misrala['x']
y_misrala = df_misrala['y']
x_BoxBOD = df_BoxBOD['x']
y_BoxBOD = df_BoxBOD['y']

# Vizualizace dat
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Misrala data
axes[0].scatter(x_misrala, y_misrala, color='blue', label='Data Misrala')
axes[0].set_title('Misrala Data')
axes[0].set_xlabel('x')
axes[0].set_ylabel('y')

# BoxBOD data
axes[1].scatter(x_BoxBOD, y_BoxBOD, color='red', label='Data BoxBOD')
axes[1].set_title('BoxBOD Data')
axes[1].set_xlabel('x')
axes[1].set_ylabel('y')

plt.tight_layout()
plt.savefig('data_visualization.png')
plt.show()

# Vytvoření dvojic (X, Y) pro regresi
datasets = {
    "misrala": (df_misrala["x"].values.reshape(-1, 1), df_misrala["y"].values),
    "BoxBOD": (df_BoxBOD["x"].values.reshape(-1, 1), df_BoxBOD["y"].values)
}

# Definice stupňů polynomu
degrees = list(range(1, 8))
max_degree = max(degrees)
# Uchování metrik pro každý dataset
metrics = {
    "misrala": {"MSE": [], "RMSE": [], "MAE": [], "R2": []},
    "BoxBOD": {"MSE": [], "RMSE": [], "MAE": [], "R2": []}
}

# Polynomiální regrese
for name, (X, y) in datasets.items():
    print(f"Processing dataset: {name}")
    # Rozdělení dat na trénovací a testovací
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

    for degree in degrees:
        poly = PolynomialFeatures(degree=degree)
        X_poly_train = poly.fit_transform(X_train)
        X_poly_test = poly.transform(X_test)

        poly_reg = LinearRegression()
        poly_reg.fit(X_poly_train, y_train)

        y_pred = poly_reg.predict(X_poly_test)

        mse = mean_squared_error(y_test, y_pred)
        rmse = np.sqrt(mse)
        mae = mean_absolute_error(y_test, y_pred)
        r2 = r2_score(y_test, y_pred)

        metrics[name]["MSE"].append(mse)
        metrics[name]["RMSE"].append(rmse)
        metrics[name]["MAE"].append(mae)
        metrics[name]["R2"].append(r2)

# Vykreslení grafů metrik vs. stupeň polynomu
fig, axes = plt.subplots(2, 2, figsize=(14, 12))

print("Metrics for Misrala:")
print(metrics["misrala"])

# Pro Misrala data
axes[0, 0].plot(degrees, metrics["misrala"]["MSE"], marker='o', color='blue', label="MSE")
axes[0, 0].set_title('Misrala - MSE vs. Stupeň polynomu')
axes[0, 0].set_xlabel('Stupeň polynomu')
axes[0, 0].set_ylabel('MSE')
axes[0, 0].legend()

axes[0, 1].plot(degrees, metrics["misrala"]["RMSE"], marker='o', color='green', label="RMSE")
axes[0, 1].set_title('Misrala - RMSE vs. Stupeň polynomu')
axes[0, 1].set_xlabel('Stupeň polynomu')
axes[0, 1].set_ylabel('RMSE')
axes[0, 1].legend()

axes[1, 0].plot(degrees, metrics["misrala"]["MAE"], marker='o', color='red', label="MAE")
axes[1, 0].set_title('Misrala - MAE vs. Stupeň polynomu')
axes[1, 0].set_xlabel('Stupeň polynomu')
axes[1, 0].set_ylabel('MAE')
axes[1, 0].legend()

axes[1, 1].plot(degrees, metrics["misrala"]["R2"], marker='o', color='purple', label="R²")
axes[1, 1].set_title('Misrala - R² vs. Stupeň polynomu')
axes[1, 1].set_xlabel('Stupeň polynomu')
axes[1, 1].set_ylabel('R²')
axes[1, 1].legend()

print("Metrics for BoxBOD:")
print(metrics["BoxBOD"])

# Pro BoxBOD data
fig.tight_layout()

fig2, axes2 = plt.subplots(2, 2, figsize=(14, 12))

axes2[0, 0].plot(degrees, metrics["BoxBOD"]["MSE"], marker='o', color='blue', label="MSE")
axes2[0, 0].set_title('BoxBOD - MSE vs. Stupeň polynomu')
axes2[0, 0].set_xlabel('Stupeň polynomu')
axes2[0, 0].set_ylabel('MSE')
axes2[0, 0].legend()

axes2[0, 1].plot(degrees, metrics["BoxBOD"]["RMSE"], marker='o', color='green', label="RMSE")
axes2[0, 1].set_title('BoxBOD - RMSE vs. Stupeň polynomu')
axes2[0, 1].set_xlabel('Stupeň polynomu')
axes2[0, 1].set_ylabel('RMSE')
axes2[0, 1].legend()

axes2[1, 0].plot(degrees, metrics["BoxBOD"]["MAE"], marker='o', color='red', label="MAE")
axes2[1, 0].set_title('BoxBOD - MAE vs. Stupeň polynomu')
axes2[1, 0].set_xlabel('Stupeň polynomu')
axes2[1, 0].set_ylabel('MAE')
axes2[1, 0].legend()

axes2[1, 1].plot(degrees, metrics["BoxBOD"]["R2"], marker='o', color='purple', label="R²")
axes2[1, 1].set_title('BoxBOD - R² vs. Stupeň polynomu')
axes2[1, 1].set_xlabel('Stupeň polynomu')
axes2[1, 1].set_ylabel('R²')
axes2[1, 1].legend()

fig2.tight_layout()

# Uložení grafů
fig.savefig('misrala_metrics_vs_degree.png')
fig2.savefig('boxbod_metrics_vs_degree.png')

plt.show()


# Nelineární regrese funkce
# Nelineární regrese funkce
def model_func(x, a, b):
    # Kontrola pro velmi malé hodnoty x, aby nedošlo k overflow
    x = np.clip(x, 1e-10, None)  # Zajistíme, že x nebude příliš malé
    return a * (1 - np.exp(-b * x))

# Funkce pro modelování a vizualizaci
def fit_and_plot(df, label, file_name):
    X = np.array(df['x'])
    y = np.array(df['y'])
    X = X.flatten()

    # Počáteční odhad pro parametry
    initial_guess = [1, 0.01]

    # Provádění křivky
    param_opt, param_cov = curve_fit(model_func, X, y, p0=initial_guess)

    # Extrahování optimalizovaných parametrů
    a_opt, b_opt = param_opt
    print(f"Optimized parameters for {label}: a = {a_opt}, b = {b_opt}")

    # Predikce na základě optimalizovaných parametrů
    y_pred = model_func(X, *param_opt)

    # Metriky
    mse_nonlinear = mean_squared_error(y, y_pred)
    rmse_nonlinear = np.sqrt(mse_nonlinear)
    r2_nonlinear = r2_score(y, y_pred)

    print(f"{label} Nonlinear Regression MSE: {mse_nonlinear}, RMSE: {rmse_nonlinear}, R2: {r2_nonlinear}")

    # Vykreslení grafu
    plt.figure(figsize=(8, 6))
    plt.scatter(X, y, color='blue', label='Data')
    plt.plot(X, y_pred, color='red', label='Nonlinear Fit')
    plt.title(f'{label} - Nonlinear Regression')
    plt.xlabel('X')
    plt.ylabel('y')
    plt.legend()

    # Uložení grafu
    plt.savefig(file_name)
    plt.show()

# Aplikování na BoxBOD a Misrala
fit_and_plot(df_BoxBOD, "BoxBOD", "BoxBOD_nonlinear_regression.png")
fit_and_plot(df_misrala, "Misrala", "Misrala_nonlinear_regression.png")

