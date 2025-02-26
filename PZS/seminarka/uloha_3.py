import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import wfdb
import time

signal, fields = wfdb.rdsamp('voice-icar-federico-ii-database-1.0.0/voice006')
signal = signal[:, 0]
Fs = fields['fs']
print(fields["comments"])
tvec = np.arange(0, len(signal) / Fs, 1 / Fs)


plt.figure(figsize=(12, 4))
plt.plot(tvec, signal, color='blue', linewidth=0.5)
plt.title("Soundwave of Vocalization 'a'")
plt.xlabel("Time (seconds)")
plt.ylabel("Amplitude")
plt.grid(True)
plt.tight_layout()
plt.show()

record = wfdb.rdrecord('voice-icar-federico-ii-database-1.0.0/voice006')
wfdb.plot_wfdb(record=record, title='Record of Vocalization "a"')
# annotation = wfdb.rdann('voice-icar-federico-ii-database-1.0.0/voice006', 'hea')
# print(annotation.__dict__)

# Plot all voice files
for i in range(1, 208):
    time.sleep(1)
    record = wfdb.rdrecord('voice-icar-federico-ii-database-1.0.0/voice' + str(i).zfill(3))
    wfdb.plot_wfdb(record=record, title='Record of Vocalization "a"')

