import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.model_selection import train_test_split
from pyloess import loess

# Načtení dat
df = pd.read_csv("manufacturing.csv")

print(df.info())
print(df.describe())

# Definujeme vstupy (X) a výstup (Y)
features = [
    "Temperature (°C)",
    "Pressure (kPa)",
    "Temperature x Pressure",
    "Material Fusion Metric",
    "Material Transformation Metric",
]

target = "Quality Rating"





for feature in features:
    print(f"Zpracovává se feature: {feature}")

    metrics = pd.DataFrame(columns=["Model", "RMSE", "R²"])

    # Rozdělení dat na trénovací a testovací
    X = df[[feature]].values  # Převod na 2D numpy pole
    y = df[target].values  # Převod na 1D numpy pole

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

    # Aplikace LOESS regrese
    X_train_new = np.linspace(X_train.min(), X_train.max(), num=len(X_train)).reshape(-1, 1)

    y_new = loess(X_train.ravel(), y_train, eval_x=X_train_new.ravel(), span=0.7, degree=2)

    y_pred = loess(X_test.ravel(), y_test, eval_x=X_test.ravel(), span=0.7, degree=2)

    # Výpočet metrik pro LOESS
    rmse_loess = np.sqrt(mean_squared_error(y_test, y_pred))
    r2_loess = r2_score(y_test, y_pred)

    # Zapsání metrik do tabulky
    metrics = pd.concat([metrics, pd.DataFrame([{"Model": "LOESS", "RMSE": rmse_loess, "R²": r2_loess}])], ignore_index=True)

    # Vizualizace výsledků
    fig, axes = plt.subplots(1, 5, figsize=(15, 6))

    axes[0].scatter(X, y, label='Original Train Data', color='blue', alpha=0.5)
    axes[0].plot(X_train_new, y_new, label='LOESS Fit', color='red', linewidth=2)
    axes[0].set_xlabel(feature)
    axes[0].set_ylabel(target)
    axes[0].set_title('LOESS Regrese')
    axes[0].legend()

    # Aplikace polynomiální regrese
    degrees = [2,3,4,5]
    for degree in degrees:
        poly = PolynomialFeatures(degree=degree)
        X_poly_train = poly.fit_transform(X_train)
        X_poly_test = poly.transform(X_test)

        model = LinearRegression()
        model.fit(X_poly_train, y_train)
        y_pred_poly = model.predict(X_poly_test)

        # Výpočet metrik pro polynomiální regresi
        rmse_poly = np.sqrt(mean_squared_error(y_test, y_pred_poly))
        r2_poly = r2_score(y_test, y_pred_poly)

        # Zapsání metrik do tabulky
        metrics = pd.concat([metrics, pd.DataFrame([{"Model": f"Polynomial {degree}", "RMSE": rmse_poly, "R²": r2_poly}])], ignore_index=True)


        axes[degree-1].scatter(X, y, label='Original Train Data', color='blue', alpha=0.5)
        axes[degree-1].plot(np.sort(X_train.ravel()),
                     np.sort(model.predict(poly.transform(X_train)).ravel()),
                     label='Polynomial Fit', color='red', linewidth=2)

        axes[degree-1].set_xlabel(feature)
        axes[degree-1].set_ylabel(target)
        axes[degree-1].set_title(f'Polynomiální regrese {degree}. stupně')
        axes[degree-1].legend()

    plt.tight_layout()
    plt.savefig(f"regression_comparison_{feature}.png", dpi=300)
    plt.show()

    print(f"Metriky pro feature: {feature}")
    print(metrics)

