import numpy as np
import wfdb
import librosa
import pandas as pd
from scipy.fft import fft, fftfreq

results = []

# Procházíme záznamy
for i in range(1, 208):
    print(f"Processing record {i}/{207} . . .")
    record = 'voice-icar-federico-ii-database-1.0.0/voice' + str(i).zfill(3)

    signal, fields = wfdb.rdsamp(record)
    signal = signal[:, 0]
    Fs = fields['fs']
    comments = fields["comments"]
    text = comments[0]
    parts = text.split("<diagnoses>:")
    diagnoses = parts[1].split("<")[0].strip()

    # Výpočet RMS (Root Mean Square)
    rms = librosa.feature.rms(y=signal)

    # Frekvenční centroid a šířka pásma
    spectral_centroid = librosa.feature.spectral_centroid(y=signal, sr=Fs)
    spectral_bandwidth = librosa.feature.spectral_bandwidth(y=signal, sr=Fs)

    # Průměrná hodnota spektrálního centroidu
    centroid_mean = np.mean(spectral_centroid)
    bandwidth_mean = np.mean(spectral_bandwidth)
    rms_mean = np.mean(rms)

    # Míra nulového průchodu
    zero_crossing_rate = librosa.feature.zero_crossing_rate(y=signal)
    zcr_mean = np.mean(zero_crossing_rate)

    # Harmonic-to-noise poměr
    hnr = librosa.effects.harmonic(signal)
    hnr_mean = np.mean(hnr)

    # **Fourierova analýza: výpočet dominantní frekvence**
    N = len(signal)
    yf = np.abs(fft(signal))[:N // 2]  # Absolutní hodnota FFT (jen kladné frekvence)
    xf = fftfreq(N, 1 / Fs)[:N // 2]  # Odpovídající frekvence
    dominant_freq = xf[np.argmax(yf)]  # Frekvence s nejvyšší amplitudou

    # **Kepstrální analýza: MFCC**
    mfccs = librosa.feature.mfcc(y=signal, sr=Fs, n_mfcc=13)
    mfcc_mean = np.mean(mfccs, axis=1)  # Průměrná hodnota MFCC (13 koeficientů)

    # Uložení výsledků do seznamu
    results.append({
        "record": str(i).zfill(3),
        "official diagnoses": diagnoses,
        "my diagnoses": None,
        "rms": np.mean(rms),
        "spectral centroid": np.mean(spectral_centroid),
        "spectral bandwidth": np.mean(spectral_bandwidth),
        "zero crossing rate": np.mean(zero_crossing_rate),
        "hnr": np.mean(hnr),
        "dominant frequency": dominant_freq,
        "mfcc1": mfcc_mean[0],  # Použití prvního MFCC
        "mfcc2": mfcc_mean[1],  # Druhý MFCC
    })

# Vytvoření DataFrame pro výsledky
df = pd.DataFrame(results)


# Funkce pro ověření shody diagnóz, vrátí počet správně detekovaných "healthy" a "pathological" diagnóz
def is_match(row):
    correct_healthy = 0
    correct_pathological = 0

    # Kontrola pro "healthy"
    if row['official diagnoses'] == 'healthy' and row['my diagnoses'] == 'healthy':  # Shoda pro healthy
        correct_healthy = 1

    # Kontrola pro "pathological"
    if row['official diagnoses'] != 'healthy' and row['my diagnoses'] == 'pathological':  # Shoda pro pathological
        correct_pathological = 1

    return correct_healthy, correct_pathological


# Funkce pro výpočet počtu správně detekovaných diagnóz
def calculate_matching_rows(rms_threshold, centroid_threshold, bandwidth_threshold, zcr_threshold, hnr_threshold,
                            freq_threshold, mfcc1_threshold, mfcc2_threshold):
    df["my diagnoses"] = df.apply(
        lambda row: classify_record_final(row["rms"], row["spectral centroid"], row["spectral bandwidth"],
                                          row["zero crossing rate"], row["hnr"], row["dominant frequency"],
                                          row["mfcc1"], row["mfcc2"],
                                          rms_threshold, centroid_threshold, bandwidth_threshold, zcr_threshold,
                                          hnr_threshold, freq_threshold, mfcc1_threshold, mfcc2_threshold), axis=1)

    correct_healthy_count = 0
    correct_pathological_count = 0
    for _, row in df.iterrows():
        healthy, pathological = is_match(row)
        correct_healthy_count += healthy
        correct_pathological_count += pathological

    return correct_healthy_count, correct_pathological_count


# Funkce pro klasifikaci záznamu na základě prahových hodnot
def classify_record_final(rms, centroid, bandwidth, zcr, hnr, dom_freq, mfcc1, mfcc2,
                          rms_threshold, centroid_threshold, bandwidth_threshold, zcr_threshold, hnr_threshold,
                          freq_threshold, mfcc1_threshold, mfcc2_threshold):
    score = 0

    if rms < rms_threshold:
        score += 1
    if centroid > centroid_threshold:
        score += 1
    if bandwidth > bandwidth_threshold:
        score += 1
    if zcr > zcr_threshold:
        score += 1
    if hnr > hnr_threshold:
        score += 1
    if dom_freq > freq_threshold:
        score += 1
    if mfcc1 > mfcc1_threshold:
        score += 1
    if mfcc2 > mfcc2_threshold:
        score += 1

    return "pathological" if score >= 5 else "healthy"

# Prahové hodnoty
rms_threshold = 0.287
centroid_threshold = 950
bandwidth_threshold = 900
zcr_threshold = 0.08
hnr_threshold = -0.0003
freq_threshold = 200
mfcc1_threshold = -100
mfcc2_threshold = 0

# Výpočet počtu shodných řádků s danými prahovými hodnotami
matching_rows = calculate_matching_rows(rms_threshold, centroid_threshold, bandwidth_threshold,
                                        zcr_threshold, hnr_threshold, freq_threshold,
                                        mfcc1_threshold, mfcc2_threshold)
print(f"Matching healthy rows: {matching_rows[0]}/{len(df[df['official diagnoses'] == 'healthy'])}")
print(f"Matching pathological rows: {matching_rows[1]}/{len(df[df['official diagnoses'] != 'healthy'])}")
print(f"Accuracy: {(matching_rows[0]+matching_rows[1])/len(df)*100:.2f} %")

# Save the results to CSV
df.to_csv("results.csv", index=False)