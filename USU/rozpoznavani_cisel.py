import numpy as np
from sklearn.datasets import load_digits
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay, classification_report
import matplotlib.pyplot as plt
from logisticka_regrese import naivni_logisticka_regrese_binarni
from sklearn.preprocessing import MinMaxScaler
from knn import knn_klasifikuj

# Načtení datasetu
digits = load_digits()
X = digits.data  # 64 příznaků pro každý vzorek
y = digits.target  # Číslice 0-9

# Rozdělení na trénovací a testovací sadu
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Normalizace dat
scaler = MinMaxScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# Inicializace modelů pro OVR
classifiers = {}

for digit in range(10):
    print(f"Trénuji model pro číslici {digit} (OVR)")
    y_binary = (y_train == digit).astype(int)  # Převod na binární problém (digit vs ostatní)

    # Naučení modelu
    model = naivni_logisticka_regrese_binarni()
    model.fit(X_train, y_binary)
    classifiers[digit] = model  # Uložíme naučené váhy

# Predikce
y_probs = np.zeros((X_test.shape[0], 10))  # Pravděpodobnosti pro všechny třídy

for digit in range(10):
    model = classifiers[digit]
    y_probs[:, digit] = model.predict_proba(X_test)

y_pred = np.argmax(y_probs, axis=1)  # Predikce třídy


# Výpočet matice záměn
conf_matrix = confusion_matrix(y_test, y_pred)

# Vykreslení matice záměn
disp = ConfusionMatrixDisplay(conf_matrix, display_labels=np.arange(10))
disp.plot()
plt.title("Logistická regrese")
plt.show()

# Classification report
print(classification_report(y_test, y_pred))


# KNN
y_pred_knn = np.zeros(X_test.shape[0])

for i, x in enumerate(X_test):
    y_pred_knn[i] = knn_klasifikuj(X_train, y_train, x, k=3)

# Výpočet matice záměn
conf_matrix_knn = confusion_matrix(y_test, y_pred_knn)

# Vykreslení matice záměn
disp = ConfusionMatrixDisplay(conf_matrix_knn, display_labels=np.arange(10))
disp.plot()
plt.title("KNN")
plt.show()

# Classification report
print(classification_report(y_test, y_pred_knn))

