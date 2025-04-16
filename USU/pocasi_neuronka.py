import tensorflow as tf
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from sklearn.metrics import classification_report, confusion_matrix, ConfusionMatrixDisplay
from tensorflow.keras.callbacks import EarlyStopping
from tensorflow.keras.layers import Dropout, LeakyReLU
from sklearn.utils.class_weight import compute_class_weight
import keras_tuner as kt

# nahrát data z csv
data = pd.read_csv("kopisty_pocasi_rozsireno.csv", sep=";")


# převod data na týden v roce
data["datum"] = pd.to_datetime(data["datum"], format="mixed")
data["tyden"] = data["datum"].dt.isocalendar().week
data["mesic"] = data["datum"].dt.month
data["rok"] = data["datum"].dt.year


# převedeme všechny sloupce, které mají čísla s čárkou
data["uhrn_srazky_1"] = data["uhrn_srazky_1"].astype(str).str.replace(",", ".")
data["uhrn_srazky_1"] = pd.to_numeric(data["uhrn_srazky_1"], errors="coerce")

data["uhrn_srazky_2"] = data["uhrn_srazky_2"].astype(str).str.replace(",", ".")
data["uhrn_srazky_2"] = pd.to_numeric(data["uhrn_srazky_2"], errors="coerce")


# prumer z uhrn_srazky_1 a uhrn_srazky_2 do jednoho sloupce
data["uhrn_srazky"] = (data["uhrn_srazky_1"] + data["uhrn_srazky_2"]) / 2

# odstranění sloupců uhrn_srazky1 a uhrn_srazky2 a datum
data = data.drop(columns=["uhrn_srazky_1", "uhrn_srazky_2", "datum", "vypar"])

# převedeme všechny sloupce, které mají čísla s čárkou
for col in data.columns:
    # pokus o převod sloupce na numerický formát
    data[col] = data[col].astype(str).str.replace(',', '.').str.strip()
    data[col] = pd.to_numeric(data[col], errors='coerce')

# odstranění řádků s chybějícími hodnotami
data = data.dropna()


# odebrání sloupců nepotřebných pro model
data = data.drop(columns=["mesic", "rok"])

# vytvoření nového sloupce, který bude obsahovat informaci o tom, zda pršelo
data["prselo"] = (data["uhrn_srazky"] > 0).astype(bool)

print(data.info())

features_to_lag = ["teplota", "tlak", "vlhkost", "rychlost_vitr", "max_naraz_vitr", "uhrn_srazky"]

# vytvořit lagy pro posledních 7 dní
for feature in features_to_lag:
    for lag in range(7):
        data[f"{feature}_lag{lag}"] = data[feature].shift(lag)

data["prselo_zitra"] = data["prselo"].shift(-1).astype(bool)

# Odstraníme řádky s NaN po vytvoření lagů
data = data.dropna()

# Vstupní vlastnosti (všechny lagované + týden)
X = data.drop(columns=["prselo", "prselo_zitra", "uhrn_srazky"])
y = data["prselo_zitra"].astype(int)  # binární klasifikace: 0 = nepršelo, 1 = pršelo

# Normalizace vstupních dat
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Rozdělení na trénovací a testovací sadu
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)


# Spočítejme váhy tříd (důležité pokud jsou nevyvážené třídy)
class_weights = compute_class_weight(class_weight='balanced', classes=np.unique(y_train), y=y_train)
class_weights_dict = {i : class_weights[i] for i in range(len(class_weights))}

# Definice modelu
def get_model():
    model = Sequential()
    model.add(Dense(128, input_dim=X_train.shape[1]))
    model.add(LeakyReLU(alpha=0.1))
    model.add(Dropout(0.3))
    
    model.add(Dense(64))
    model.add(LeakyReLU(alpha=0.1))
    model.add(Dropout(0.3))

    model.add(Dense(32))
    model.add(LeakyReLU(alpha=0.1))
    
    model.add(Dense(1, activation='sigmoid'))

    optimizer = tf.keras.optimizers.Adam(learning_rate=0.0005)
    model.compile(optimizer=optimizer, loss='binary_crossentropy', metrics=['accuracy'])
    return model


# Callbacks
early_stop = EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True)

EPOCHS = 50
model = get_model()
history = model.fit(
    X_train, 
    y_train, 
    epochs=EPOCHS, 
    batch_size=32,
    validation_split=0.2, 
    callbacks=[early_stop], 
    class_weight=class_weights_dict
    )

# Vyhodnocení modelu
loss, accuracy = model.evaluate(X_test, y_test)
print(f"Test Loss: {loss}, Test Accuracy: {accuracy}")

# Confusion matrix display
conf_matrix = confusion_matrix(y_test, (model.predict(X_test) > 0.5).astype(int))
disp = ConfusionMatrixDisplay(confusion_matrix=conf_matrix, display_labels=[0, 1])
disp.plot(cmap=plt.cm.Blues)
plt.title("Confusion Matrix")
plt.show()

plt.rcParams["figure.figsize"] = [12,4]
figure, axis = plt.subplots(1, 2)

axis[0].plot(history.history['loss'], label='loss - training data')
axis[0].plot(history.history['val_loss'], label='loss - validating data')
axis[0].grid()
axis[0].set_title('Loss')
axis[0].legend()



axis[1].plot(history.history['accuracy'], label='accuracy - training data')
axis[1].plot(history.history['val_accuracy'], label='accuracy - validating data')
axis[1].grid()
axis[1].set_title('Accuracy')
axis[1].legend()

plt.show()

# # Hyperparameter tuning using Keras Tuner


# def build_model(hp):
#     model = Sequential()
    
#     # První skrytá vrstva
#     model.add(Dense(
#         units=hp.Int('units_input', min_value=32, max_value=256, step=32),
#         input_dim=X_train.shape[1]
#     ))
#     model.add(LeakyReLU(alpha=0.1))
#     model.add(Dropout(hp.Float('dropout_input', 0.0, 0.5, step=0.1)))

#     # Další vrstvy
#     for i in range(hp.Int('num_layers', 1, 3)):
#         model.add(Dense(units=hp.Int(f'units_{i}', 32, 256, step=32)))
#         model.add(LeakyReLU(alpha=0.1))
#         model.add(Dropout(hp.Float(f'dropout_{i}', 0.0, 0.5, step=0.1)))

#     # Výstupní vrstva
#     model.add(Dense(1, activation='sigmoid'))

#     # Optimalizátor
#     lr = hp.Float('learning_rate', min_value=1e-4, max_value=1e-2, sampling='log')
#     optimizer = tf.keras.optimizers.Adam(learning_rate=lr)
    
#     model.compile(optimizer=optimizer, loss='binary_crossentropy', metrics=['accuracy'])
#     return model

# # Tuner
# tuner = kt.RandomSearch(
#     build_model,
#     objective='val_accuracy',
#     max_trials=10,
#     executions_per_trial=2,
#     overwrite=True,
#     directory='keras_tuner_dir',
#     project_name='prselo_tuning'
# )

# # Callbacks
# early_stop = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True)

# # Spustit hledání
# tuner.search(
#     X_train, y_train,
#     epochs=50,
#     validation_split=0.2,
#     callbacks=[early_stop],
#     class_weight=class_weights_dict,
#     verbose=1
# )

# # Nejlepší model
# best_model = tuner.get_best_models(num_models=1)[0]

# # Vyhodnocení nejlepšího modelu
# loss, accuracy = best_model.evaluate(X_test, y_test)
# print(f"Best Test Loss: {loss:.4f}, Best Test Accuracy: {accuracy:.4f}")

# # Confusion matrix
# y_pred = (best_model.predict(X_test) > 0.5).astype(int)
# conf_matrix = confusion_matrix(y_test, y_pred)
# disp = ConfusionMatrixDisplay(confusion_matrix=conf_matrix, display_labels=["Nepršelo", "Pršelo"])
# disp.plot(cmap=plt.cm.Blues)
# plt.title("Confusion Matrix (Best Model)")
# plt.grid(False)
# plt.show()

# # Přesnost, recall, F1
# print(classification_report(y_test, y_pred))