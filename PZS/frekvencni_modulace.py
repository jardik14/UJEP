from matplotlib import pyplot as plt
import numpy as np

# Frekvenční modulace

t = np.linspace(0, 1, 1000)

# nosná vlna
f = 2 # frekvence
A = 1 # amplituda
y = A * np.sin(2 * np.pi * f * t) # vlnový průběh

# modulující vlna
f_m = 13
A_m = 3
y_m = A_m * np.sin(2 * np.pi * f_m * t)

# modulovaná vlna
y_mod = A * np.sin(2 * np.pi * f * t + y_m)

# plt.plot(t, y, label='nosná vlna')
# plt.plot(t, y_m, label='modulující vlna')
plt.plot(t, y_mod, label='modulovaná vlna')
plt.legend()
plt.xlabel('t')
plt.ylabel('signal')
plt.title('Frekvenční modulace')
plt.show()