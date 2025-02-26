import os
import scipy.signal as signal
import pandas as pd
import wfdb

def find_anomalies(ecg_signal, Fs):
    """
    Funkce pro detekci anomálií v EKG signálu.

    Parametry:
    - ecg_signal: EKG signál jako jednorozměrné pole
    - Fs: Vzorkovací frekvence EKG signálu (Hz)

    Výstup:
    - anomalies: Seznam tuple (start, end) indikující anomální segmenty
    """
    # Nastavení pásmového filtru pro odstranění šumu
    lowcut = 5.0
    highcut = 15.0
    nyquist = 0.5 * Fs
    b, a = signal.butter(1, [lowcut / nyquist, highcut / nyquist], btype='band')
    filtered_ecg = signal.filtfilt(b, a, ecg_signal)

    # Získání čtvercované hodnoty signálu pro detekci vrcholů
    squared_signal = filtered_ecg ** 2

    # Parametry pro detekci R-vrcholu
    peak_height_threshold = 200000
    peak_distance_threshold = 150
    r_peaks = signal.find_peaks(squared_signal, height=peak_height_threshold, distance=peak_distance_threshold, threshold=0.2)[0]

    # Detekce anomálií: Úseky mezi R vrcholy
    window_size = 400  # Min. délka segmentu
    anomalies = []
    for i in range(1, len(r_peaks)):
        # Vzorek mezi dvěma R-vrcholy
        start_idx = r_peaks[i-1]
        end_idx = r_peaks[i]
        segment = ecg_signal[start_idx:end_idx]
        if len(segment) < window_size:  # Příliš krátký segment, pravděpodobně poškozený
            anomalies.append((start_idx, end_idx))

    return anomalies

def combine_neighbouring_anomalies(anomalies):
    """
    Sloučí sousedící anomálie do jedné.

    Parametry:
    - anomalies: Seznam tuple (start, end) indikujících anomální segmenty

    Výstup:
    - anomalies: Seznam tuple (start, end) indikujících anomální segmenty
    """
    combined_anomalies = []
    start = anomalies[0][0]
    end = anomalies[0][1]
    for i in range(1, len(anomalies)):
        if anomalies[i][0] - end <= 200:  # Pokud jsou anomálie blízko, sloučíme je
            end = anomalies[i][1]
        else:
            combined_anomalies.append((start, end))
            start = anomalies[i][0]
            end = anomalies[i][1]
    combined_anomalies.append((start, end))

    return combined_anomalies


def load_annotations(csv_path):
    """
    Načte anotace anomálií z CSV souboru.

    Parametry:
    - csv_path: Cesta k souboru s anotacemi

    Výstup:
    - list: Seznam dvojic (start, end) časových intervalů anomálií
    """
    # Načtení CSV souboru bez hlavičky
    annotations = pd.read_csv(csv_path, header=None)
    # První dva sloupce obsahují začátek a konec anomálie
    annotation_start = annotations.iloc[:, 0].values
    annotation_end = annotations.iloc[:, 1].values

    # Vrátíme seznam dvojic (start, end)
    return list(zip(annotation_start, annotation_end))


def compare_anomalies(detected_anomalies, annotated_anomalies):
    """
    Porovná nalezené anomálie s anotacemi a spočítá poče správně detekovaných anomálií.

    Parametry:
    - detected_anomalies: seznam tuple (start, end) nalezených anomálií
    - annotated_anomalies: seznam tuple (start, end) anotovaných anomálií

    Výstup:
    - Počet správně detekovaných anomálií.
    """
    matching_count = 0
    matched_annotations = []  # Uchováme již spárované anotace

    for detected_start, detected_end in detected_anomalies:
        for annotated_start, annotated_end in annotated_anomalies:
            # Zkontrolujeme, zda se anomálie překrývají
            if (detected_start < annotated_end and detected_end > annotated_start):
                # Pokud ano, přičteme k počtu správně detekovaných anomálií
                matching_count += 1
                matched_annotations.append((annotated_start, annotated_end))
                break  # Přejdeme na další detekovanou anomálii

    return matching_count


# Definice adresáře s datovými soubory
directory_path = 'brno-university-of-technology-ecg-quality-database-but-qdb-1.0.0/'

Fs = 1000  # Vzorkovací frekvence (Hz)

results = []
# Procházíme adresářovou strukturu
for dirpath, dirnames, filenames in os.walk(directory_path):
    for filename in filenames:
        if filename.endswith('ECG.dat'):

            filename = filename[:-4]
            print(f"Zpracovávám {filename}...")
            # Kompletní cesta k .dat souboru
            file_path = os.path.join(dirpath, filename)

            # Načtení EKG signálu
            ecg_signal = wfdb.rdrecord(file_path).p_signal.flatten()

            # Detekce anomálií
            anomalies = find_anomalies(ecg_signal, Fs)

            # Sloučení sousedících anomálií
            anomalies = combine_neighbouring_anomalies(anomalies)

            # Načítání anotací
            annotation_filename = filename.replace('ECG', 'ANN.csv')
            annotation_file_path = os.path.join(dirpath, annotation_filename)
            annotations = load_annotations(annotation_file_path)

            # Useknutí anotací podle délky signálu
            annotations = [(start, end) for start, end in annotations if end < len(ecg_signal)]

            # Porovnání nalezených anomálií s anotacemi
            correct_anomalies = compare_anomalies(anomalies, annotations)
            total_annotations = len(annotations)

            # Uložení výsledků
            results.append({
                'Název': filename[:-4],
                'Nalezených anomálií': len(anomalies),
                'Anotovaných anomálií': total_annotations,
                'Anomálie v anotovaném úseku': correct_anomalies
            })

# Vytvoření tabulky s výsledky
table = pd.DataFrame(results)
print(table)

# Uložení výsledků do CSV souboru
table.to_csv('anomalie_vysledky.csv', index=False)
