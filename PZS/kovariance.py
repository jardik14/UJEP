import numpy as np
import matplotlib.pyplot as plt
import scipy as sp

#kovariance na dvě různé přímkové funkce

t = np.linspace(0, 10, 100, endpoint=True)

#funkce 1
x1 = sp.signal.sawtooth(2 * np.pi * 0.5 * t)

#funkce 2
x2 = sp.signal.square(2 * np.pi * 0.5 * t)

#funkce 3
x3 = np.sin(t)

#funkce 4 (náhodný signál)
x4 = np.random.normal(0, 0.3, t.shape)

#kovariance
def kovariance(x1, x2):
    return  1/(len(x1)-1) * np.sum((x1 - np.mean(x1)) * (x2 - np.mean(x2)))
print(kovariance(x1, x2))
print(np.cov(x1, x2))
print(np.cov(x1, x3) == kovariance(x1, x3))
print(np.cov(x1, x4))
print(np.cov(x2, x3))
print(np.cov(x2, x4))
print(np.cov(x3, x4))

plt.plot(t, x1, label='funkce 1')
plt.plot(t, x2, label='funkce 2')
plt.plot(t, x3, label='funkce 3')
plt.plot(t, x4, label='náhodný signál')
plt.legend()
plt.xlabel('t')
plt.ylabel('signal')
plt.title('Kovariance')
plt.show()
