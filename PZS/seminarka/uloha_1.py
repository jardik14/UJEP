"""
Zadání:
Ve zdrojové databázi najdete celkem 18 měření EKG signálu pro různé věkové skupiny. Signál
obsahuje různé anomálie a nemusí být vždy centralizován podle vodorovné osy. EKG signál
obsahuje dominantní peaky, které se nazývají R vrcholy. Vzdálenost těchto vrcholů určuje dobu
mezi jednotlivými tepy. Počet tepů za minutu je tedy počet R vrcholů v signálu o délce jedné
minuty. Navrhněte algoritmus, který bude automaticky detekovat počet R vrcholů v EKG
signálech a prezentujte tepovou frekvenci při jednotlivých jízdách/měřeních. Vás algoritmus
následně otestujte na databázi MIT-BIH https://physionet.org/content/nsrdb/1.0.0/ a
prezentujte jeho úspěšnost vzhledem k anotovaným datům z databáze.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import find_peaks, butter, filtfilt
import wfdb

# Načtení dat z .dat souboru
data1 = np.fromfile('brno-university-of-technology-ecg-quality-database-but-qdb-1.0.0/105001/105001_ECG.dat', dtype=np.int16)

# Sampling rate
sampling_rate = 1000  # Hz


def butter_bandpass(lowcut, highcut, fs, order=4):
    nyquist = 0.5 * fs
    low = lowcut / nyquist
    high = highcut / nyquist
    b, a = butter(order, [low, high], btype='band')
    return b, a

def bandpass_filter(data, lowcut, highcut, fs, order=4):
    b, a = butter_bandpass(lowcut, highcut, fs, order)
    y = filtfilt(b, a, data)
    return y

# Parametry filtru
lowcut = 0.5  # dolní mez (v Hz)
highcut = 50.0  # horní mez (v Hz)

# Zobrazení poseldních 1000 vzorků signálu
data_segment = data1[:40000]

# Filtrování signálu
filtered_data_segment = bandpass_filter(data_segment, lowcut, highcut, sampling_rate)

# Detekce R vrcholů
peaks, _ = find_peaks(filtered_data_segment, height=500, distance=400, threshold=0.2)


# Zobrazení signálu a detekovaných R vrcholů
time = np.arange(len(filtered_data_segment)) / sampling_rate  # časová osa v sekundách
plt.figure(figsize=(12, 6))
plt.plot(time, filtered_data_segment, label="Filtrováno EKG", color="blue")
plt.plot(time[peaks], filtered_data_segment[peaks], 'rx', label="Detekované R vrcholy")
plt.title("Detekce R vrcholů v EKG signálu")
plt.xlabel("Čas (s)")
plt.ylabel("Amplitude")
plt.legend()
plt.grid()
plt.show()

# Rozdělení signálu na minuty
samples_per_minute = sampling_rate * 60  # 1000 vzorků/s * 60 s = 60 000 vzorků za minutu

# Výpočet bpm pro každou minutu
bpm_per_minute = []
time_in_minutes = []

# Filtrování signálu
filtered_data = bandpass_filter(data1, lowcut, highcut, sampling_rate)

# Projdeme signál v krocích po minutách
for i in range(0, len(filtered_data), samples_per_minute):
    minute_signal = filtered_data[i:i + samples_per_minute]

    # Detekce vrcholů pro tuto minutu
    minute_peaks, _ = find_peaks(minute_signal, height=500, distance=400)

    # Spočítáme tepovou frekvenci (bpm) pro tuto minutu
    bpm = len(minute_peaks)  # počet vrcholů za minutu
    bpm_per_minute.append(bpm)
    time_in_minutes.append(i / samples_per_minute)

# Výpočet průměrné tepové frekvence
average_bpm = np.mean(bpm_per_minute)
print(f"Průměrná tepová frekvence: {average_bpm:.2f} bpm")

# Vykreslení grafu
plt.figure(figsize=(12, 6))
plt.plot(time_in_minutes, bpm_per_minute,color='b')
plt.title("Tepová frekvence (bpm) v závislosti na čase")
plt.xlabel("Čas (minuty)")
plt.ylabel("Tepová frekvence (bpm)")
plt.grid(True)
plt.show()
