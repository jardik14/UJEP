import os
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import find_peaks, butter, filtfilt
import pandas as pd
import wfdb


def butter_bandpass(lowcut, highcut, fs, order=4):
    """
    Vytvoří koeficienty Butterworthova pásmového filtru.

    Parametry:
    lowcut (float) - Dolní mezní frekvence filtru (Hz).
    highcut (float) - Horní mezní frekvence filtru (Hz).
    fs (float) - Vzorkovací frekvence signálu (Hz).
    order (int) - Řád filtru (výchozí hodnota je 4).

    Vrací:
    b, a - Koeficienty filtru..
    """
    nyquist = 0.5 * fs
    low = lowcut / nyquist
    high = highcut / nyquist
    b, a = butter(order, [low, high], btype='band')
    return b, a


def bandpass_filter(data, lowcut, highcut, fs, order=4):
    """
    Aplikuje Butterworthův pásmový filtr na vstupní signál.

    Parametry:
    data (array-like) - Vstupní signál k filtraci.
    lowcut (float) - Dolní mezní frekvence filtru (Hz).
    highcut (float) - Horní mezní frekvence filtru (Hz).
    fs (float) - Vzorkovací frekvence signálu (Hz).
    order (int) - Řád filtru (výchozí hodnota je 4).

    Vrací:
    y (array-like) - Filtrovaný signál.
    """
    b, a = butter_bandpass(lowcut, highcut, fs, order)
    y = filtfilt(b, a, data)
    return y


def find_rpeaks(signal, fs, samples_per_window=60000):
    """
    Detekuje R-vrcholy v EKG signálu.

    Parametry:
    signal (array-like) - EKG signál.
    fs (int) - Vzorkovací frekvence signálu (Hz).
    samples_per_window (int) - Počet vzorků v okně pro detekci vrcholů.

    Vrací:
    peaks (list) - Seznam indexů detekovaných R-vrcholů.
    """
    peaks = []
    for i in range(0, len(signal), samples_per_window):
        window_signal = signal[i:i + samples_per_window]
        peak_height_threshold = np.percentile(window_signal, 95)
        peak_distance_threshold = fs//2
        window_peaks, _ = find_peaks(window_signal, height=peak_height_threshold, distance=peak_distance_threshold)
        peaks.extend(window_peaks + i)

    return peaks


def calculate_bpm(signal, fs=1000, samples_per_window=60000):
    """
    Vypočítá srdeční frekvenci (BPM) ze signálu EKG.

    Parametry:
    signal (array-like) - EKG signál.
    fs (int) - Vzorkovací frekvence signálu (výchozí 1000 Hz).
    samples_per_window (int) - Počet vzorků v okně pro detekci vrcholů (výchozí 60000).

    Vrací:
    bpm_per_minute (list) - Seznam hodnot BPM pro každou analyzovanou minutu.
    time_in_minutes (list) - Seznam časových značek v minutách odpovídajících vypočítaným BPM.
    """
    bpm_per_minute = []  # Seznam BPM pro každou analyzovanou minutu
    time_in_minutes = []  # Seznam časových značek v minutách

    # Zavolání funkce find_rpeaks pro získání vrcholů z celého signálu
    rpeaks = find_rpeaks(signal, fs, samples_per_window=samples_per_window)

    for i in range(0, len(signal), samples_per_window):  # Přecházíme po minutách

        # Filtrování R-vrcholů pro aktuální minutu
        minute_rpeaks = [rpeak for rpeak in rpeaks if i <= rpeak < i + samples_per_window]

        bpm = len(minute_rpeaks)  # Počet detekovaných R-vrcholů odpovídající BPM

        bpm_per_minute.append(bpm)
        time_in_minutes.append(i / fs / 60)  # Čas v minutách

    return bpm_per_minute, time_in_minutes


def visualize_bpm(signal, bpm, time):
    """
    Vykreslí graf tepové frekvence (BPM) v závislosti na čase.

    Parametry:
    signal (array-like) - EKG signál.
    bpm (array-like) - Seznam hodnot BPM pro každou analyzovanou minutu.
    time (array-like) - Seznam časových značek v minutách odpovídajících vypočítaným BPM.
    """
    plt.figure(figsize=(10, 5))
    plt.plot(time, bpm, linestyle='-', color='r')
    plt.title("Tepová frekvence (BPM)")
    plt.xlabel("Čas (minuty)")
    plt.ylabel("BPM")
    plt.grid(True)
    plt.show()


def calculate_accuracy(found_peaks, actual_peaks, threshold=10):
    """
    Vypočítá přesnost detekce R-vrcholu.

    Parametry:
    found_peaks (array-like) - Detekované R-vrcholy.
    actual_peaks (array-like) - Skutečné R-vrcholy.
    threshold (int) - Tolerovaná odchylka (ve vzorcích).

    Vrací:
    correct_peaks (int) - Počet správně detekovaných R-vrcholu.
    false_peaks (int) - Počet falešně detekovaných R-vrcholu.
    total_peaks (int) - Celkový počet R-vrcholu v signálu.
    accuracy (float) - Přesnost detekce v procentech.
    """
    correct_peaks = 0
    total_peaks = len(actual_peaks)

    for actual_peak in actual_peaks:
        for found_peak in found_peaks:
            if abs(actual_peak - found_peak) <= threshold:
                correct_peaks += 1
                found_peaks.remove(found_peak)
                break

    accuracy = (correct_peaks / total_peaks) * 100

    return correct_peaks, total_peaks - correct_peaks, total_peaks, accuracy



bpm_results = []
# Definování adresáře obsahujícího soubory
directory_path = 'brno-university-of-technology-ecg-quality-database-but-qdb-1.0.0/'
i = 0

# Procházení adresářové struktury a zpracování souborů
for dirpath, dirnames, filenames in os.walk(directory_path):
    for filename in filenames:
        if filename.endswith('ECG.dat'):
            print(f"Zpracovávám soubor {filename}...")
            # Plná cesta k souboru .dat
            file_path = os.path.join(dirpath, filename)

            # Načtení EKG signálu
            signal = np.fromfile(file_path, dtype=np.int16)

            sampling_rate = 1000  # Hz (vzorkovací frekvence)

            # Detekce R-vrcholů v signálu
            found_peaks = find_rpeaks(signal, sampling_rate)

            # Výpočet BPM (tepové frekvence)
            bpm, time = calculate_bpm(signal)
            visualize_bpm(signal, bpm, time)
            average_bpm = np.mean(bpm)
            print(f"Průměrná tepová frekvence (BPM): {average_bpm:.2f}")

            # Uložení výsledků do seznamu
            bpm_results.append({
                'název_souboru': filename,
                'průměrné_BPM': f"{average_bpm:.2f}"
            })

bpm_table = pd.DataFrame(bpm_results)
print(bpm_table)

test_results = []
# Definování adresáře obsahujícího testovací soubory
directory_path = 'ecg_test_data/'

max_samples = 600000 # 10 minut (zkráceno pro rychlejší běh)

# Procházíme adresářovou strukturu a zpracováváme soubory
for dirpath, dirnames, filenames in os.walk(directory_path):
    for filename in filenames:
        if filename.endswith('.dat'):

            # Odstranění přípony souboru
            filename = filename[:-4]
            print(f"Zpracovávám soubor {filename}...")
            # Plná cesta k souboru .dat
            file_path = os.path.join(dirpath, filename)

            # Načtení EKG signálu
            signal, fields = wfdb.rdsamp(file_path, channels=None, sampto=max_samples)
            signal = signal[:, 0]  # Použití pouze prvního kanálu
            sampling_rate = fields['fs']  # Vzorkovací frekvence signálu

            # Detekce R-vrcholů v signálu
            found_peaks = find_rpeaks(signal, sampling_rate, 60000)
            # Načtení skutečných R-vrcholů z anotací
            actual_peaks = wfdb.rdann(file_path, 'atr', sampto=max_samples).sample

            # Nastavení prahu pro vyhodnocení správnosti detekce (10 % očekávaného RR intervalu, cca 100 ms)
            threshold = int(0.1 * sampling_rate)
            correct_peaks, false_peaks, total_peaks, accuracy = calculate_accuracy(found_peaks, actual_peaks, threshold)

            # Uložení výsledků analýzy do seznamu
            test_results.append({
                'název_souboru': filename,
                'správné_vrcholy': correct_peaks,
                'falešné_vrcholy': false_peaks,
                'celkový_počet_vrcholů': total_peaks,
                'přesnost': f"{round(accuracy, 2)} %",
            })

# Vytvoření tabulky výsledků testování
test_table = pd.DataFrame(test_results)
print(test_table)

# Zápis tabulky výsledků do CSV souboru
test_table.to_csv('test_results.csv', index=False)

# Výpočet celkové přesnosti detekce R-vrcholů
total_accuracy = test_table['správné_vrcholy'].sum() / test_table['celkový_počet_vrcholů'].sum() * 100
print(f"Celková přesnost detekce R-vrcholů: {total_accuracy:.2f} %")