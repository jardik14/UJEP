import numpy as np
import matplotlib.pyplot as plt
import random
from scipy import interpolate



# sine function
x = np.linspace(0, 2 * np.pi, 50)
y = np.sin(x)


x_interpol = np.linspace(0, 2 * np.pi, 10)
y_interpol = np.sin(x_interpol)
y_noised = y_interpol.copy()

# add noise
for i in range(len(y_interpol)):
    y_noised[i] += random.uniform(-0.1, 0.1)



# 1-D interpolation
y_1d = interpolate.interp1d(x_interpol, y_interpol)
xnew = np.linspace(0, 2 * np.pi, 100)
ynew = y_1d(xnew)

# Lagrange interpolation
y_lagrange = interpolate.lagrange(x_interpol, y_interpol)
xphi = np.linspace(0, 2 * np.pi, 100)
phi = y_lagrange(xphi)


plt.plot(xphi, phi, "m-")
plt.plot(xnew, ynew, "r-")
plt.plot(x_interpol, y_interpol, "b.")
# plt.plot(x, y, "g-")
plt.title("Sine")
plt.show()




# logarithm function
x = np.linspace(1, 2 * np.pi, 50)
y = np.log2(x)

x_interpol = np.linspace(1, 2 * np.pi, 10)
y_interpol = np.log2(x_interpol)
y_noised = y_interpol.copy()

# add noise
for i in range(len(y_noised)):
    y_noised[i] += random.uniform(-0.1, 0.1)


# 1-D interpolation
y_1d = interpolate.interp1d(x_interpol, y_interpol)
xnew = np.linspace(1, 2 * np.pi, 10)
ynew = y_1d(xnew)

# Lagrange interpolation
y_lagrange = interpolate.lagrange(x_interpol, y_interpol)
xphi = np.linspace(1, 2 * np.pi, 100)
phi = y_lagrange(xphi)


plt.plot(xphi, phi, "m-")
plt.plot(xnew, ynew, "r-")
plt.plot(x_interpol, y_interpol, "b.")
plt.plot(x, y, "g-")
plt.title("Logarithm")
plt.show()

# square root function
x = np.linspace(1, 2 * np.pi, 50)
y = np.sqrt(x)

x_interpol = np.linspace(1, 2 * np.pi, 10)
y_interpol = np.sqrt(x_interpol)
y_noised = y_interpol.copy()

# add noise
for i in range(len(y_noised)):
    y_noised[i] += random.uniform(-0.1, 0.1)

# 1-D interpolation
y_1d = interpolate.interp1d(x, y_noised)
xnew = np.linspace(1, 2 * np.pi, 100)
ynew = y_1d(xnew)

# Lagrange interpolation
y_lagrange = interpolate.lagrange(x_interpol, y_interpol)
xphi = np.linspace(1, 2 * np.pi, 100)
phi = y_lagrange(xphi)


plt.plot(xphi, phi, "m-")
plt.plot(xnew, ynew, "r-")
plt.plot(x_interpol, y_interpol, "b.")
plt.plot(x, y, "g-")
plt.title("Exponential")
plt.show()


