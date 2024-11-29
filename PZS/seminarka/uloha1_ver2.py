import os
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import find_peaks, butter, filtfilt
import pandas as pd

# Define the directory containing the files
directory_path = 'brno-university-of-technology-ecg-quality-database-but-qdb-1.0.0/'


# Function to apply bandpass filtering
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


# Function to calculate bpm for a single signal
def calculate_bpm(signal, sampling_rate=1000, samples_per_minute=60000):
    bpm_per_minute = []
    time_in_minutes = []
    for i in range(0, len(signal), samples_per_minute):
        minute_signal = signal[i:i + samples_per_minute]
        peaks, _ = find_peaks(minute_signal, height=500, distance=400)
        bpm = len(peaks)  # Convert to bpm
        bpm_per_minute.append(bpm)
        time_in_minutes.append(i / samples_per_minute)
    return bpm_per_minute, time_in_minutes

results = []
sampling_rate = 1000  # Hz


# Traverse through the directory structure
for dirpath, dirnames, filenames in os.walk(directory_path):
    for filename in filenames:
        if filename.endswith('ECG.dat'):  # Process only ECG.dat files
            # Full path to the .dat file
            file_path = os.path.join(dirpath, filename)

            # Load the EKG signal
            signal = np.fromfile(file_path, dtype=np.int16)

            # Filter the signal
            filtered_signal = bandpass_filter(signal, lowcut=0.5, highcut=50.0, fs=sampling_rate)

            # Calculate bpm
            bpm, time = calculate_bpm(filtered_signal, sampling_rate, sampling_rate * 60)

            average_bpm = np.mean(bpm)

            print(f"Average bpm for {filename}: {average_bpm:.2f}")

            results.append({
                'filename': filename,
                'average_bpm': average_bpm
            })

            # Plot bpm for the current file
            plt.figure(figsize=(10, 5))
            plt.plot(time, bpm, linestyle='-', color='r')
            plt.title(f"Tepová frekvence (bpm) - {filename}")
            plt.xlabel("Čas (minuty)")
            plt.ylabel("Tepová frekvence (bpm)")
            plt.grid(True)
            plt.show()

table = pd.DataFrame(results)
print(table)