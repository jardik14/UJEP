from matplotlib import pyplot as plt
import numpy as np

# nosná vlna
f = 1 # frekvence
A = 1 # amplituda
t = np.linspace(0, 1, 1000) # časová osa
y = A * np.sin(2 * np.pi * f * t) # vlnový průběh

# modulující vlna
f_m = 10
A_m = 0.5
y_m = A_m * np.sin(2 * np.pi * f_m * t)

# modulovaná vlna
y_mod = (A + y_m) * np.sin(2 * np.pi * f * t)

plt.plot(t, y, label='nosná vlna')
plt.plot(t, y_m, label='modulující vlna')
plt.plot(t, y_mod, label='modulovaná vlna')
plt.legend()
plt.show()