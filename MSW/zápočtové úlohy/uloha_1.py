from functools import wraps
import time
import numpy as np
import pandas as pd
import math

def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"Elapsed time: {end - start}")
        return result
    return wrapper

# Dot product

@timer
def dot_product_python(a, b):
    return sum(x * y for x, y in zip(a, b))

@timer
def dot_product_numpy(a, b):
    return np.dot(a, b)

@timer
def dot_product_pandas(a, b):
    return pd.Series(a).dot(pd.Series(b))

# Matrix multiplication

@timer
def matrix_multiplication_python(a, b):
    return [[sum(x * y for x, y in zip(row, col)) for col in zip(*b)] for row in a]

@timer
def matrix_multiplication_numpy(a, b):
    return np.dot(a, b)

@timer
def matrix_multiplication_pandas(a, b):
    return pd.DataFrame(a).dot(pd.DataFrame(b))

# Scaler addition

@timer
def scaler_addition_python(a, b):
    return [x + b for x in a]

@timer
def scaler_addition_numpy(a, b):
    return a + b

@timer
def scaler_addition_pandas(a, b):
    return pd.Series(a) + b

# Matrix addition

@timer
def matrix_addition_python(a, b):
    return [[x + y for x, y in zip(row_a, row_b)] for row_a, row_b in zip(a, b)]

@timer
def matrix_addition_numpy(a, b):
    return a + b

@timer
def matrix_addition_pandas(a, b):
    return pd.DataFrame(a) + pd.DataFrame(b)

# Creating zero matrix

@timer
def zeroing_matrix_python(a):
    return [[0 for _ in row] for row in a]

@timer
def zeroing_matrix_numpy(a):
    return np.zeros_like(a)

@timer
def zeroing_matrix_pandas(a):
    return pd.DataFrame(a) * 0








def main():
    a = np.random.rand(10000000)
    b = np.random.rand(10000000)
    print("Dot product:")
    print(" Python:")
    dot_product_python(a, b)
    print(" Numpy:")
    dot_product_numpy(a, b)
    print(" Pandas:")
    dot_product_pandas(a, b)

    a = np.random.rand(300, 300)
    b = np.random.rand(300, 300)
    print("\nMatrix multiplication:")
    print(" Python:")
    matrix_multiplication_python(a, b)
    print(" Numpy:")
    matrix_multiplication_numpy(a, b)
    print(" Pandas:")
    matrix_multiplication_pandas(a, b)

    a = np.random.rand(10000000)
    b = 1
    print("\nScaler addition:")
    print(" Python:")
    scaler_addition_python(a, b)
    print(" Numpy:")
    scaler_addition_numpy(a, b)
    print(" Pandas:")
    scaler_addition_pandas(a, b)

    a = np.random.rand(1000, 1000)
    b = np.random.rand(1000, 1000)
    print("\nMatrix addition:")
    print(" Python:")
    matrix_addition_python(a, b)
    print(" Numpy:")
    matrix_addition_numpy(a, b)
    print(" Pandas:")
    matrix_addition_pandas(a, b)

    a = np.random.rand(1000, 1000)
    print("\nZeroing matrix:")
    print(" Python:")
    zeroing_matrix_python(a)
    print(" Numpy:")
    zeroing_matrix_numpy(a)
    print(" Pandas:")
    zeroing_matrix_pandas(a)




if __name__ == "__main__":
    main()