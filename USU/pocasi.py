# Zjistit korelaci veličin
# na základě posledního týdne předpověď jstli bude pršet
# vstupem meteo veličiny plus datum
# sklearn.ensemble udělat model z modelů (stackmodel)
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, f1_score, classification_report, confusion_matrix, ConfusionMatrixDisplay
from sklearn.ensemble import StackingClassifier
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import KFold
from sklearn.model_selection import GridSearchCV

# nahrát data z csv
data = pd.read_csv("kopisty_pocasi_rozsireno.csv", sep=";")

# zobrazit prvních 5 řádků
print(data.head())

# zobrazit informace o datasetu
print(data.info())

# převod data na týden v roce
data["datum"] = pd.to_datetime(data["datum"], format="mixed")
data["tyden"] = data["datum"].dt.isocalendar().week
data["mesic"] = data["datum"].dt.month
data["rok"] = data["datum"].dt.year

# zobrazení prvních 5 řádků
print(data.head())

# převedeme všechny sloupce, které mají čísla s čárkou
data["uhrn_srazky_1"] = data["uhrn_srazky_1"].astype(str).str.replace(",", ".")
data["uhrn_srazky_1"] = pd.to_numeric(data["uhrn_srazky_1"], errors="coerce")

data["uhrn_srazky_2"] = data["uhrn_srazky_2"].astype(str).str.replace(",", ".")
data["uhrn_srazky_2"] = pd.to_numeric(data["uhrn_srazky_2"], errors="coerce")




print(data.head(n=10))

# prumer z uhrn_srazky_1 a uhrn_srazky_2 do jednoho sloupce
data["uhrn_srazky"] = (data["uhrn_srazky_1"] + data["uhrn_srazky_2"]) / 2

# odstranění sloupců uhrn_srazky1 a uhrn_srazky2 a datum
data = data.drop(columns=["uhrn_srazky_1", "uhrn_srazky_2", "datum", "vypar"])

# převedeme všechny sloupce, které mají čísla s čárkou
for col in data.columns:
    # pokus o převod sloupce na numerický formát
    data[col] = data[col].astype(str).str.replace(',', '.').str.strip()
    data[col] = pd.to_numeric(data[col], errors='coerce')

# zobrazení prvních 10 řádků
print(data.head(n=10))
print(data.info())
print(data.describe())

# odstranění řádků s chybějícími hodnotami
data = data.dropna()

# korelační matice
print(data.corr())

# zobrazení korelační matice
plt.figure(figsize=(12, 10))
sns.heatmap(data.corr(), annot=True, cmap="coolwarm")
plt.title("Korelační matice")
plt.show()

# odebrání sloupců nepotřebných pro model
data = data.drop(columns=["mesic", "rok"])

# vytvoření nového sloupce, který bude obsahovat informaci o tom, zda pršelo
data["prselo"] = (data["uhrn_srazky"] > 0).astype(bool)

print(data.head(n=10))



# model logistické regrese pro predikci, zda bude pršet, podle posledního týdne
# seznam proměnných, které chceme posunout
features_to_lag = ["teplota", "tlak", "vlhkost", "rychlost_vitr", "max_naraz_vitr", "uhrn_srazky"]

# vytvořit lagy pro posledních 7 dní
for feature in features_to_lag:
    for lag in range(7):
        data[f"{feature}_lag{lag}"] = data[feature].shift(lag)

data["prselo_zitra"] = data["prselo"].shift(-1).astype(bool)



data = data.dropna()

lag_features = [col for col in data.columns if "_lag" in col]
X = data[lag_features]
y = data["prselo_zitra"]

# normalizace dat
scaler = StandardScaler()
X = scaler.fit_transform(X)


X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)


model = LogisticRegression()
model.fit(X_train, y_train)

y_pred = model.predict(X_test)
print(classification_report(y_test, y_pred))

# conf_matrix = confusion_matrix(y_test, y_pred)
# disp = ConfusionMatrixDisplay(conf_matrix, display_labels=[False, True])
# disp.plot()
# plt.show()


# vytvoření KFold splitu
kf = KFold(n_splits=5, shuffle=True, random_state=42)

accuracies = []
f1_scores = []

X = pd.DataFrame(X)
y = pd.Series(y)

X = X.reset_index(drop=True)
y = y.reset_index(drop=True)

for train_index, test_index in kf.split(X, y):
    X_train_k, X_test_k = X.iloc[train_index], X.iloc[test_index]
    y_train_k, y_test_k = y.iloc[train_index], y.iloc[test_index]

    # stacking model
    stack_model = StackingClassifier(
        estimators=[
            ('rf', RandomForestClassifier(n_estimators=100, class_weight='balanced')),
            ('gb', GradientBoostingClassifier()),
            ('svc', SVC(probability=True)),
            ('lr', LogisticRegression(class_weight='balanced'))
        ],
        final_estimator=LogisticRegression(class_weight='balanced'),
        n_jobs=-1
    )

    stack_model.fit(X_train_k, y_train_k)
    y_pred_k = stack_model.predict(X_test_k)

    acc = accuracy_score(y_test_k, y_pred_k)
    f1 = f1_score(y_test_k, y_pred_k)

    accuracies.append(acc)
    f1_scores.append(f1)

    print(f"Fold - Accuracy: {acc:.3f}, F1-score: {f1:.3f}")

    # # výpis confusion matrix
    # conf_matrix = confusion_matrix(y_test_k, y_pred_k)
    # disp = ConfusionMatrixDisplay(conf_matrix, display_labels=[False, True])
    # disp.plot()
    # plt.title(f"Stacking model - fold")
    # plt.show()

# průměrné výsledky
print("\nPrůměrné výsledky z 5-fold cross-validace:")
print(f"Průměrná přesnost: {sum(accuracies)/len(accuracies):.3f}")
print(f"Průměrné F1 skóre: {sum(f1_scores)/len(f1_scores):.3f}")

# grid search pro hledání optimálních parametrů
base_estimators = [
    ('rf', RandomForestClassifier()),
    ('gb', GradientBoostingClassifier()),
    ('svc', SVC(probability=True))
]

stack_model = StackingClassifier(
    estimators=base_estimators,
    final_estimator=LogisticRegression(),
    n_jobs=-1
)

param_grid = {
    'rf__n_estimators': [50, 100],
    'gb__learning_rate': [0.05, 0.1],
    'svc__C': [0.5, 1, 2],
    'final_estimator__C': [0.1, 1, 10]  # parametry finálního modelu
}

grid = GridSearchCV(
    estimator=stack_model,
    param_grid=param_grid,
    cv=5,
    scoring='f1',
    verbose=2,
    n_jobs=-1
)

grid.fit(X_train, y_train)

best_stack_model = grid.best_estimator_
y_pred = best_stack_model.predict(X_test)
print(classification_report(y_test, y_pred))



