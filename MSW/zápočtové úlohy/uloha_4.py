import numpy as np
import matplotlib.pyplot as plt
import random
from scipy import interpolate



# sine function
x = np.linspace(0, 2 * np.pi, 100)
y = np.sin(x)


x_interpol = np.linspace(0, 2 * np.pi, 6)
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

# BSpline interpolation
tck = interpolate.splrep(x_interpol, y_interpol)
x_bspline = np.linspace(0, 2 * np.pi, 100)
y_bspline = interpolate.splev(x_bspline, tck)


plt.plot(xnew, ynew, "r-")
plt.plot(xphi, phi, "m-")
plt.plot(x_bspline, y_bspline, "y-")
plt.plot(x_interpol, y_interpol, "b.")
# plt.plot(x, y, "g-")
plt.legend(["1-D interpolation", "Lagrange interpolation", "BSpline interpolation" , "Data"])
plt.title("Sine")
plt.show()

# porovnání přesnosti interpolace pomocí součtu čtverců (rozptyylů)
ctverce_1D = 0
for i in range(len(y)):
    ctverce_1D += (y[i] - y_1d(x)[i])**2

ctverce_lagrange = 0
for i in range(len(y)):
    ctverce_lagrange += (y[i] - y_lagrange(x)[i])**2

ctverce_bspline = 0
for i in range(len(y)):
    ctverce_bspline += (y[i] - y_bspline[i])**2

print("1-D interpolation: ", ctverce_1D)
print("Lagrange interpolation: ", ctverce_lagrange)
print("BSpline interpolation: ", ctverce_bspline)




# logarithm function
x = np.linspace(1, 2 * np.pi, 100)
y = np.log2(x)

x_interpol = np.linspace(1, 2 * np.pi, 5)
y_interpol = np.log2(x_interpol)
y_noised = y_interpol.copy()

# add noise
for i in range(len(y_noised)):
    y_noised[i] += random.uniform(-0.1, 0.1)


# 1-D interpolation
y_1d = interpolate.interp1d(x_interpol, y_interpol)
xnew = np.linspace(1, 2 * np.pi, 100)
ynew = y_1d(xnew)

# Lagrange interpolation
y_lagrange = interpolate.lagrange(x_interpol, y_interpol)
xphi = np.linspace(1, 2 * np.pi, 100)
phi = y_lagrange(xphi)

# BSpline interpolation
tck = interpolate.splrep(x_interpol, y_interpol)
x_bspline = np.linspace(1, 2 * np.pi, 100)
y_bspline = interpolate.splev(x_bspline, tck)

plt.plot(xnew, ynew, "r-")
plt.plot(xphi, phi, "m-")
plt.plot(x_bspline, y_bspline, "y-")
plt.plot(x_interpol, y_interpol, "b.")
# plt.plot(x, y, "g-")
plt.legend(["1-D interpolation", "Lagrange interpolation", "BSpline interpolation" , "Data"])
plt.title("Logarithm")
plt.show()


ctverce_1D = 0
for i in range(len(y)):
    ctverce_1D += (y[i] - y_1d(x)[i])**2

ctverce_lagrange = 0
for i in range(len(y)):
    ctverce_lagrange += (y[i] - y_lagrange(x)[i])**2

ctverce_bspline = 0
for i in range(len(y)):
    ctverce_bspline += (y[i] - y_bspline[i])**2

print("1-D interpolation: ", ctverce_1D)
print("Lagrange interpolation: ", ctverce_lagrange)
print("BSpline interpolation: ", ctverce_bspline)


# square root function
x = np.linspace(1, 2 * np.pi, 100)
y = np.sqrt(x)

x_interpol = np.linspace(1, 2 * np.pi, 5)
y_interpol = np.sqrt(x_interpol)
y_noised = y_interpol.copy()

# add noise
for i in range(len(y_noised)):
    y_noised[i] += random.uniform(-0.1, 0.1)

# 1-D interpolation
y_1d = interpolate.interp1d(x_interpol, y_interpol)
xnew = np.linspace(1, 2 * np.pi, 100)
ynew = y_1d(xnew)

# Lagrange interpolation
y_lagrange = interpolate.lagrange(x_interpol, y_interpol)
xphi = np.linspace(1, 2 * np.pi, 100)
phi = y_lagrange(xphi)

# BSpline interpolation
tck = interpolate.splrep(x_interpol, y_interpol)
x_bspline = np.linspace(1, 2 * np.pi, 100)
y_bspline = interpolate.splev(x_bspline, tck)

plt.plot(xnew, ynew, "r-")
plt.plot(xphi, phi, "m-")
plt.plot(x_bspline, y_bspline, "y-")
plt.plot(x_interpol, y_interpol, "b.")
# plt.plot(x, y, "g-")
plt.legend(["1-D interpolation", "Lagrange interpolation", "BSpline interpolation" , "Data"])
plt.title("Square root")
plt.show()

ctverce_1D = 0
for i in range(len(y)):
    ctverce_1D += (y[i] - y_1d(x)[i])**2

ctverce_lagrange = 0
for i in range(len(y)):
    ctverce_lagrange += (y[i] - y_lagrange(x)[i])**2

ctverce_bspline = 0
for i in range(len(y)):
    ctverce_bspline += (y[i] - y_bspline[i])**2

print("1-D interpolation: ", ctverce_1D)
print("Lagrange interpolation: ", ctverce_lagrange)
print("BSpline interpolation: ", ctverce_bspline)

