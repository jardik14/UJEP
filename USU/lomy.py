# Předpověď třídy z obrázků
import cv2
import matplotlib.pyplot as plt
import xgboost as xgb
from sklearn.ensemble import RandomForestClassifier
import numpy as np
import os
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix, ConfusionMatrixDisplay

def compute_histogram(image_path):
    # Načtení obrázku v odstínech šedi
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

    # Výpočet histogramu (256 úrovní jasu)
    hist = cv2.calcHist([img], [0], None, [256], [0, 256])

    # Normalizace histogramu (volitelná)
    hist = hist.flatten()  # Převedení na 1D pole

    return hist

def plot_histogram(hist):
    plt.figure(figsize=(8, 4))
    plt.plot(hist, color='black')
    plt.title("Histogram")
    plt.xlabel("Intenzita")
    plt.ylabel("Počet pixelů")
    plt.grid()
    plt.show()

# Použití na konkrétním obrázku
image_path = "lomy/stepnylom_jpg/01_300.jpg"
histogram = compute_histogram(image_path)
plot_histogram(histogram)

# Příprava dat
# Načtení dat
X = []
y = []

# Adresáře s obrázky (každá složka je jedna třída)
data_dir = "lomy"
classes = os.listdir(data_dir)

# Načtení dat
for i, cl in enumerate(classes):
    class_dir = os.path.join(data_dir, cl)
    for file in os.listdir(class_dir):
        img_path = os.path.join(class_dir, file)
        hist = compute_histogram(img_path)
        X.append(hist)
        y.append(i)

X = np.array(X)

# Rozdělení na trénovací a testovací data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Trénování modelu
model = RandomForestClassifier()
model.fit(X_train, y_train)

# Vyhodnocení modelu
accuracy = model.score(X_test, y_test)
print(f"Přesnost modelu RandomForest: {accuracy}")
report = classification_report(y_test, model.predict(X_test))
print(report)
conf_matrix = confusion_matrix(y_test, model.predict(X_test))
disp = ConfusionMatrixDisplay(conf_matrix, display_labels=classes)
disp.plot()
plt.show()

# ----------------------------------------
# XGBoost

# Trénování modelu
modelxgb = xgb.XGBClassifier()
modelxgb.fit(X_train, y_train)

# Vyhodnocení modelu
accuracy = modelxgb.score(X_test, y_test)
print(f"Přesnost modelu XGBoost: {accuracy}")
report = classification_report(y_test, modelxgb.predict(X_test))
print(report)
conf_matrix = confusion_matrix(y_test, modelxgb.predict(X_test))
disp = ConfusionMatrixDisplay(conf_matrix, display_labels=classes)
disp.plot()
plt.show()

# ----------------------------------------
# Random Forest with k-fold cross-validation
from sklearn.model_selection import cross_val_score

model = RandomForestClassifier()
scores = cross_val_score(model, X, y, cv=5)
print(f"Cross-validation scores: {scores}")
print(f"Average accuracy: {np.mean(scores)}")




