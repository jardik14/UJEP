import numpy as np
from scipy import optimize
from functools import wraps
import time


def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        return (end - start) * 1000, result
    return wrapper

@timer
def bisect(f, a, b):
    return optimize.bisect(f, a, b)

@timer
def newton(f, x0):
    return optimize.newton(f, x0)


# funkce 1
print("Funkce 1: x^2 - 4")
def f1(x):
    return x**2 - 4

a0 = 0
b0 = 4

res = 4**(1/2)

# bisekce
cas, x = bisect(f1, a0, b0)
print(f"Bisekce: {x}, čas: {cas} ms, chyba: {abs(res - x)}")


# newton
cas, x = newton(f1, x0=(a0+b0)/2)
print(f"Newton: {x}, čas: {cas} ms, chyba: {abs(res - x)}")


# funkce 2
print("\nFunkce 2: x^3 - 4")
def f2(x):
    return np.exp(x) - 4

a0 = 0
b0 = 4


res = np.log(4)

# bisekce
cas, x = bisect(f2, a0, b0)
print(f"Bisekce: {x}, čas: {cas} ms, chyba: {abs(res - x)}")


# newton
cas, x = newton(f2, x0=(a0+b0)/2)
print(f"Newton: {x}, čas: {cas} ms, chyba: {abs(res - x)}")


# funkce 3
print("\nFunkce 3: 2 * sin(x) - 0.5")
def f3(x):
    return 2 * np.sin(x) - 0.5

a0 = -2
b0 = 2

res = np.arcsin(0.25)

# bisekce
cas, x = bisect(f3, a0, b0)
print(f"Bisekce: {x}, čas: {cas} ms, chyba: {abs(res - x)}")


# newton
cas, x = newton(f3, x0=(a0+b0)/2)
print(f"Newton: {x}, čas: {cas} ms, chyba: {abs(res - x)}")
