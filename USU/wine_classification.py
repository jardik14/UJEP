from sklearn.datasets import load_wine
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.metrics import accuracy_score
from sklearn.linear_model import LogisticRegression
import warnings
warnings.filterwarnings("ignore")


data = load_wine()

# Nalezněte optimální parametry logistické regrese (penalty, C, solver) pomocí GridSearchCV
X = data.data
y = data.target

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

scaler = MinMaxScaler()

X_train = scaler.fit_transform(X_train)

model = LogisticRegression()

param_grid = {
    'penalty': ['l1', 'l2'],
    'C': [0.01, 0.1, 1, 10, 100],
    'solver': ['liblinear', 'lbfgs']
}

grid = GridSearchCV(model, param_grid, cv=5, n_jobs=-1, verbose=2)
grid.fit(X_train, y_train)

print(f"Best params: {grid.best_params_}")

print(grid.best_estimator_)

# Natrénujte model s nalezenými parametry a vyhodnoťte jeho přesnost na testovací sadě
model = grid.best_estimator_


X_test = scaler.transform(X_test)
y_pred = model.predict(X_test)

print(f"Accuracy: {accuracy_score(y_test, y_pred)}")


