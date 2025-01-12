import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import wfdb

signal, fields = wfdb.rdsamp('voice-icar-federico-ii-database-1.0.0/voice006')
signal = signal[:, 0]
Fs = fields['fs']
tvec = np.arange(0, len(signal) / Fs, 1 / Fs)

plt.figure(figsize=(12, 4))
plt.plot(tvec, signal, color='blue', linewidth=0.5)
plt.title("Soundwave of Vocalization 'a'")
plt.xlabel("Time (seconds)")
plt.ylabel("Amplitude")
# plt.xlim([1, 2])  # Zoom in between 2 and 3 seconds
plt.grid(True)
plt.tight_layout()
plt.show()

# Perform Fourier Transform
freqs = np.fft.fftfreq(len(signal), 1 / Fs)
spectrum = np.fft.fft(signal)

# Plot the frequency spectrum
plt.figure(figsize=(12, 4))
plt.plot(freqs[:len(freqs)//2], np.abs(spectrum)[:len(spectrum)//2])
plt.title("Frequency Spectrum")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude")
plt.grid(True)
plt.tight_layout()
plt.show()
