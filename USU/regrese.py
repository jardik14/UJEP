import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.linear_model import LogisticRegression


# Načtení dat
data = pd.read_csv("HousingData.csv")
print(data.info())

# Rozdělení na trénovací a testovací data
X = data.drop('MEDV', axis=1)
y = data['MEDV']

# normalizace dat
scaler = MinMaxScaler()
Xn = scaler.fit_transform(X)


beta = np.linalg.solve(Xn.T @ Xn, Xn.T @ y)
print(f"Váhy beta: {beta}")

