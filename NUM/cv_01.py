import numpy as np

# Create random matrix with whole numbers
n = 4 # dimension
A = np.random.randint(0, 10, (n, n))
A[0, 0] = 0

# Create random vector with whole numbers
b = np.random.randint(0, 10, n)

def Gauss(A, b):
    n = len(b)
    Ab = np.c_[A, b]
    print(Ab)
    # Forward elimination
    for i in range(n):
        # pivot (highest absolute value in column)
        pivot = np.argmax(np.abs(Ab[i:, i])) + i
        if pivot != i:
            # swap rows
            Ab[[i, pivot]] = Ab[[pivot, i]]
        for j in range(i+1, n):
            m = Ab[j, i] / Ab[i, i] # multiplier
            Ab[j, i:] = Ab[j, i:] - m * Ab[i, i:] # row operation

    return Ab


Ab = Gauss(A, b)
print(Ab)