import os
import numpy as np
import matplotlib.pyplot as plt
import scipy.signal as signal
import pandas as pd

ecg_signal = np.fromfile('brno-university-of-technology-ecg-quality-database-but-qdb-1.0.0/100001/100001_ECG.dat', dtype=np.int16)
# ecg_signal = ecg_signal[:5000]
Fs = 1000  # Hz
T = 1/Fs
n_length = len(ecg_signal)
tvec = np.arange(0, n_length*T, T)

def find_anomalies(ecg_signal, Fs):
    lowcut = 5.0
    highcut = 15.0
    nyquist = 0.5 * Fs
    b, a = signal.butter(1, [lowcut / nyquist, highcut / nyquist], btype='band')
    filtered_ecg = signal.filtfilt(b, a, ecg_signal)

    squared_signal = filtered_ecg ** 2

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

    # Zobrazení poškozených segmentů
    # plt.plot(tvec, squared_signal, label="Squared ECG", color='green')
    # plt.plot(r_peaks / Fs, squared_signal[r_peaks], 'rx', label="Detected R peaks")
    # for anomaly in anomalies:
    #     start_time = anomaly[0] * T
    #     end_time = anomaly[1] * T
    #     plt.axvspan(start_time, end_time, color='orange', alpha=0.5)  # Zobrazení poškozených segmentů
    # plt.title("Squared ECG Signal with Detected R Peaks and Identified Anomalies")
    # plt.xlabel("Time (s)")
    # plt.ylabel("Amplitude")
    # plt.legend()
    # plt.show()

    return anomalies

# Define the directory containing the files
directory_path = 'brno-university-of-technology-ecg-quality-database-but-qdb-1.0.0/'

results = []
# Traverse through the directory structure
for dirpath, dirnames, filenames in os.walk(directory_path):
    for filename in filenames:
        if filename.endswith('ECG.dat'):  # Process only ECG.dat files
            # Full path to the .dat file
            file_path = os.path.join(dirpath, filename)

            # Load the EKG signal
            ecg_signal = np.fromfile(file_path, dtype=np.int16)

            # Detect anomalies
            anomalies = find_anomalies(ecg_signal, Fs)
            total_time = len(ecg_signal) / Fs

            results.append({
                'filename': filename,
                'recording time': total_time,
                'anomalies count': len(anomalies),
                'average anomalies per minute': len(anomalies) / (total_time / 60)
            })

table = pd.DataFrame(results)
print(table)