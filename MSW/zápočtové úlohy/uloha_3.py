import numpy as np
from functools import wraps
import time
import matplotlib.pyplot as plt

def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        # print(f"Elapsed time: {end - start}")
        return end - start
    return wrapper


# generate a random matrix of k x k+1 size
def generate_matrix(k):
    x = np.random.rand(k, k)
    x *= 10
    x = np.round(x)
    x = x.astype(int)
    return x

def generate_vector(k):
    x = np.random.rand(k)
    x *= 10
    x = np.round(x)
    x = x.astype(int)
    return x

@timer
def gaussian_elimination(A, b):
    n = len(A)

    Ab = np.column_stack((A, b)).astype(np.float64)

    for i in range(n):
        if Ab[i, i] == 0.0:
            return None
        for j in range(i + 1, n):
            ratio = Ab[j, i] / Ab[i, i]
            Ab[j] -= ratio * Ab[i]

    x = np.zeros(n)
    for i in range(n - 1, -1, -1):
        x[i] = (Ab[i, -1] - np.dot(Ab[i, :-1], x)) / Ab[i, i]

    return x

@timer
def gauss_seidel(A, b, niteraci, x0):
    try:
        x = x0
        U = np.triu(A, k = 1)
        Lstar = np.tril(A, k = 0)
        T = np.matmul(-np.linalg.inv(Lstar), U)
        C = np.matmul(np.linalg.inv(Lstar), b)
        for i in range(niteraci):
            x = np.matmul(T, x) + C
        return x
    except:
        return None


gauss_times = []
gauss_seidel_times = []

max_size = 300
increment = 10

for i in range(1, max_size, increment):
    gauss_times_partial = []
    gauss_seidel_times_partial = []
    for _ in range(50):
        A = generate_matrix(i)
        b = generate_vector(i)
        gauss_times_partial.append(gaussian_elimination(A, b))
        gauss_seidel_times_partial.append(gauss_seidel(A, b, 20, np.ones(len(A))))
    while None in gauss_times_partial:
        gauss_times_partial.remove(None)
    gauss_times.append(np.mean(gauss_times_partial))
    while None in gauss_seidel_times_partial:
        gauss_seidel_times_partial.remove(None)
    gauss_seidel_times.append(np.mean(gauss_seidel_times_partial))

plt.plot(range(1, max_size, increment), gauss_times, label="Gaussian elimination")
plt.plot(range(1, max_size, increment), gauss_seidel_times, label="Gauss-Seidel")
plt.xlabel("Matrix size")
plt.ylabel("Time")
plt.legend()
plt.show()

