import os
import numpy as np
import matplotlib.pyplot as plt
import scipy.signal as signal
import pandas as pd


ecg_signal = np.fromfile('brno-university-of-technology-ecg-quality-database-but-qdb-1.0.0/100001/100001_ECG.dat', dtype=np.int16)
ecg_signal = ecg_signal[:5000]
Fs = 1000  # Hz
T = 1/Fs
n_length = 3840
tvec = np.arange(0, n_length*T, T)



def pan_tompkins(ecg_signal, sampling_rate=1000):
    plt.figure(figsize=(12, 6))
    plt.subplot(3, 3, 1)
    plt.plot(ecg_signal, label="Original ECG", color='red')
    plt.title("Original ECG Signal")
    plt.xlabel("Time (s)")
    plt.ylabel("Amplitude")
    plt.legend()

    # Step 1: Bandpass Filter (5-15 Hz)
    lowcut = 5.0
    highcut = 15.0
    nyquist = 0.5 * sampling_rate
    b, a = signal.butter(1, [lowcut / nyquist, highcut / nyquist], btype='band')
    filtered_ecg = signal.filtfilt(b, a, ecg_signal)

    # Plot
    plt.subplot(3, 2, 2)
    plt.plot(filtered_ecg, color='blue')
    plt.title("Band Pass Filtered ECG Signal")
    plt.xlabel("Time (s)")
    plt.ylabel("Amplitude")

    # Step 2: Derivative (Emphasize slope information)
    derivative = np.ediff1d(filtered_ecg)

    # Plot
    plt.subplot(3, 2, 3)
    plt.plot(derivative, color='green')
    plt.title("Derivative ECG Signal")
    plt.xlabel("Time (s)")
    plt.ylabel("Amplitude")

    # Step 3: Squaring (Non-linear amplification)
    squared_signal = derivative ** 2

    # Plot
    plt.subplot(3, 2, 4)
    plt.plot(squared_signal, color='purple')
    plt.title("Squared ECG Signal")
    plt.xlabel("Time (s)")
    plt.ylabel("Amplitude")

    # Step 4: Moving Window Integration
    window_size = int(0.150 * sampling_rate)  # 150 ms window
    integration_window = np.ones(window_size) / window_size
    integrated_signal = np.convolve(squared_signal, integration_window, mode='same')


    # Step 5: Thresholding
    threshold = 0.6 * np.max(integrated_signal)  # Adjustable threshold

    # Plot
    plt.subplot(3, 2, 5)
    plt.plot(integrated_signal, label="Integrated ECG", color='orange')
    plt.axhline(threshold, color='red', linestyle='--', label="Threshold")
    plt.title("Integrated ECG Signal with Threshold")
    plt.xlabel("Time (s)")
    plt.ylabel("Amplitude")
    plt.legend()

    plt.tight_layout()
    plt.show()
    return integrated_signal

pan_tompkins(ecg_signal, Fs)
