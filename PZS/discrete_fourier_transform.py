import numpy as np
import matplotlib.pyplot as plt

def discrete_fourier_transform(signal):
    N = len(signal)
    S = np.zeros(N, dtype=complex)
    for k in range(N):
        for n in range(N):
            S[k] += signal[n] * np.exp(-2j * np.pi * k * n / N)
    return S

# change small numbers to 0 for complex type
def round_complex(x):
    if abs(x.real) < 1e-10:
        x = complex(0, round(x.imag,2))
    if abs(x.imag) < 1e-10:
        x = complex(round(x.real,2), 0)
    return x

signal = np.array([8,4,8,0])
S = discrete_fourier_transform(signal)

# round small numbers to 0
S = np.array([round_complex(x) for x in S])

for i in range(len(S)):
    print(f"S[{i}] = {S[i]}")

# get absolute values of S
S_abs = np.abs(S)
print(S_abs)

# plot the signal
plt.plot(S_abs, 'o')
plt.stem(S_abs)
plt.title("Spektrum signálu")
plt.xlabel("f")
plt.ylabel("s(f)")
plt.show()

def signal(A0, f, tvec):
    vals = A0*np.cos(2*np.pi*f*tvec)
    return np.array(vals)

def err(A0, f, tvec):
    vals = A0*2*np.random.random(len(tvec)) - A0
    return np.array(vals)


A0 = 2
f = 10

tvec = np.linspace(0, 1, 500)

st_original = signal(A0, f, tvec)
st = signal(A0, f, tvec)
et = err(A0, f, tvec)

st = st + et

plt.plot(tvec, st)
plt.plot(tvec, st_original, color='r')
plt.title("Signál")
plt.xlabel("t")
plt.ylabel("s(t)")
plt.show()

# fourier with treshold to clean the noise
fourier = np.fft.fft(st)
plt.plot(np.abs(fourier))
plt.title("Spektrum signálu")
plt.xlabel("f")
plt.ylabel("s(f)")
plt.show()

threshold = 55
fourier[np.abs(fourier) < threshold] = 0

plt.plot(np.abs(fourier))
plt.title("Spektrum signálu po čištění")
plt.xlabel("f")
plt.ylabel("s(f)")
plt.show()

st_clean = np.fft.ifft(fourier)


plt.plot(tvec, st_clean)
plt.plot(tvec, st_original, color='r')
plt.title("Signál po čištění")
plt.xlabel("t")
plt.ylabel("s(t)")
plt.show()