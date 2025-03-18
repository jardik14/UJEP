import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix, classification_report, roc_curve, auc

# Načtení datasetu
df = pd.read_csv("diabetes.csv")
print(df.info())
print(df.describe())

# Předzpracování dat
# Zpracování chybějících hodnot (např. odstranění nebo imputace)
df = df.dropna()

# Rozdělení na vstupní a výstupní proměnné
X = df.drop("Outcome", axis=1)
y = df["Outcome"]

# Normalizace numerických atributů
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Rozdělení na trénovací a testovací sadu (70:30)
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.3, random_state=42)

# Trénování modelů
models = {
    "Logistic Regression": LogisticRegression(),
    "Decision Tree": DecisionTreeClassifier(),
    "Random Forest": RandomForestClassifier()
}

for name, model in models.items():
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)

    print(f"\n{name}:")
    print("Confusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    print("Classification Report:")
    print(classification_report(y_test, y_pred))

    # ROC křivka a AUC
    y_prob = model.predict_proba(X_test)[:, 1] if hasattr(model, "predict_proba") else y_pred
    fpr, tpr, _ = roc_curve(y_test, y_prob)
    roc_auc = auc(fpr, tpr)
    plt.plot(fpr, tpr, label=f'{name} (AUC = {roc_auc:.2f})')

plt.plot([0, 1], [0, 1], 'k--')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC Curve')
plt.legend()
plt.show()

"""
Přesnosti modelů se výrazně neliší, ale Logistická regrese má nejlepší výsledky na základě klíčových metrik (precision, recall, f1-score).
Random Forest má nejlepší AUC.
"""

# Načtení datasetu
df = pd.read_csv("framingham.csv")
print(df.info())
print(df.describe())

# Předzpracování dat
# Zpracování chybějících hodnot (např. odstranění nebo imputace)
df = df.dropna()

# Rozdělení na vstupní a výstupní proměnné
X = df.drop("diabetes", axis=1)
y = df["diabetes"]

# Normalizace numerických atributů
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Rozdělení na trénovací a testovací sadu (70:30)
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.3, random_state=42)

# Trénování modelů
models = {
    "Logistic Regression": LogisticRegression(),
    "Decision Tree": DecisionTreeClassifier(),
    "Random Forest": RandomForestClassifier()
}

for name, model in models.items():
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)

    print(f"\n{name}:")
    print("Confusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    print("Classification Report:")
    print(classification_report(y_test, y_pred))

    # ROC křivka a AUC
    y_prob = model.predict_proba(X_test)[:, 1] if hasattr(model, "predict_proba") else y_pred
    fpr, tpr, _ = roc_curve(y_test, y_prob)
    roc_auc = auc(fpr, tpr)
    plt.plot(fpr, tpr, label=f'{name} (AUC = {roc_auc:.2f})')

plt.plot([0, 1], [0, 1], 'k--')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC Curve')
plt.legend()
plt.show()

"""
Metriky modelů na tomto datsetu se již lišily více.
Nejlepší výsledky metrik má opět Logistická regrese, která má zároveň i nejlepší AUC.
"""

