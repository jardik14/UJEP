from matplotlib import pyplot as plt
import numpy as np
import scipy as sp

# Konvoluce

t = np.linspace(0, 8, 100, endpoint=True)

# signál
# x = sp.signal.square(2 * np.pi * 0.5 * t)
# x = np.where(t >= 1.0, 0, x)

# zašuměný signál
x = sp.signal.square(2 * np.pi * 0.5 * t) + np.random.normal(0, 0.1, t.shape)

# jádro
alpha = 1
a = 2
h =alpha * np.exp(-a*t)

# konvoluce
conv = np.convolve(x, h, mode='full')
# skalovani
conv = conv / np.max(conv)

t_conv = np.linspace(0, 16, np.max(conv.shape))

# graf
plt.plot(t, x, label='signál')
plt.plot(t, h, label='jádro')
plt.plot(t_conv, conv, label='konvoluce')
plt.legend()
plt.xlabel('t')
plt.ylabel('signal')
plt.title('Konvoluce')
plt.show()