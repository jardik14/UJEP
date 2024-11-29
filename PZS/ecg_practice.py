from scipy.misc import electrocardiogram
import matplotlib.pyplot as plt
import pywt
import numpy as np
from scipy.signal import find_peaks

def wavelet_denoise(signal, wavelet="db6", level=6):
    # Perform wavelet decomposition
    coeffs = pywt.wavedec(signal, wavelet, level=level)
    # Estimate noise level (using robust statistics on the detail coefficients)
    sigma = np.median(np.abs(coeffs[-1])) / 0.6745
    threshold = sigma * np.sqrt(2 * np.log(len(signal)))
    # Thresholding: Soft threshold applied to detail coefficients
    denoised_coeffs = [pywt.threshold(c, threshold, mode='soft') if i > 0 else c
                       for i, c in enumerate(coeffs)]
    # Reconstruct the denoised signal
    return pywt.waverec(denoised_coeffs, wavelet)



EKG = electrocardiogram()
Fs = 360


T = 1/Fs
n_length = EKG.size

tvec = np.arange(0, n_length) * T

Signal = EKG

total_time = len(Signal) / Fs # in seconds

# Apply wavelet denoising to the ECG signal
denoised_ecg = wavelet_denoise(Signal, level=4)

# Plot the original and denoised signals
plt.figure(figsize=(12, 6))
plt.subplot(3, 1, 1)
plt.plot(tvec, Signal, label="Original ECG", color='red')
plt.title("Original ECG Signal")
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.legend()

plt.subplot(3, 1, 2)
plt.plot(tvec[:len(denoised_ecg)], denoised_ecg, label="Denoised ECG", color='blue')
plt.title("Denoised ECG Signal")
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.legend()

# Perform Cepstral Analysis
fft_ecg = np.fft.fft(denoised_ecg)  # Fourier Transform
log_magnitude_spectrum = np.log(np.abs(fft_ecg))  # Logarithm of magnitude spectrum
cepstrum = np.fft.ifft(log_magnitude_spectrum).real  # Inverse Fourier Transform to cepstrum

# Extract quefrency values
quefrency = np.arange(len(cepstrum)) / Fs

plt.subplot(3, 1, 3)
plt.plot(quefrency[:len(cepstrum)//2], np.abs(cepstrum[:len(cepstrum)//2]), label="Cepstrum")
plt.title("Cepstrum of Denoised ECG Signal")
plt.xlabel("Quefrency (s)")
plt.ylabel("Magnitude")
plt.legend()


plt.tight_layout()
plt.show()

# Find R-peaks
# Adjust `height` and `distance` based on your signal's characteristics
peaks, _ = find_peaks(denoised_ecg, height=0.6, distance=Fs*0.4)  # 0.6s = typical RR interval at 60 bpm

# Plot ECG with detected R-peaks
plt.figure(figsize=(12, 6))
plt.plot(tvec, denoised_ecg, label="ECG Signal")
plt.plot(tvec[peaks], denoised_ecg[peaks], "x", label="R-peaks", color="red")
plt.title("R-peak Detection")
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.legend()
plt.show()

average_bpm = len(peaks) / total_time * 60
print(f"Average BPM: {average_bpm:.2f}")