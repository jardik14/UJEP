import matplotlib.pyplot as plt
import numpy as np

pocet_period = 100
pocet_vzorku = 10000
pocet_vzorku_na_periodu = pocet_vzorku // pocet_period

#signál
x = np.sin(np.linspace(0, pocet_period*2*np.pi, pocet_vzorku))

#šum
sum = np.random.normal(0, 1, pocet_vzorku)

#přidání šumu k signálu
y = x + sum

# rozdeleni signalu na jednotlive periody
periody = []
for i in range(pocet_period):
    perioda = y[i*pocet_vzorku_na_periodu:(i+1)*pocet_vzorku_na_periodu]
    periody.append(perioda)

#graf
plt.plot(y)
plt.show()



# prumer kazdeho bodu pres veshny periody da vysledny signal
vysledny_signal = np.mean(periody, axis=0)
puvodni_signal = np.sin(np.linspace(0, 2*np.pi, pocet_vzorku//pocet_period))

# plt.plot(periody[0], label='První perioda')
plt.plot(vysledny_signal, label='Výsledný signál')
plt.plot(puvodni_signal, label='Původní signál')
plt.legend()
plt.xlabel('Vzorky')
plt.ylabel('Hodnota')
plt.title('Kumulační technika')
plt.show()


# signál se zvyšujícím se šumem
for i in range(pocet_period):
    sum = np.random.normal(0, i/10, pocet_vzorku_na_periodu)
    y[i*pocet_vzorku_na_periodu:(i+1)*pocet_vzorku_na_periodu] += sum

plt.plot(y)
plt.show()

q = (pocet_period - 1) / (pocet_period + 1)

# rozdeleni signalu na jednotlive periody
periody = []
for i in range(pocet_period):
    perioda = y[i*pocet_vzorku_na_periodu:(i+1)*pocet_vzorku_na_periodu]
    # perioda *=
    periody.append(perioda)

# # sumace vsech period s ruznými vahami
# suma = np.zeros(pocet_vzorku_na_periodu)
# for i in range(pocet_period):
#     suma += periody[i] * (1/(i+1))
#
#
# vysledny_signal = suma / np.sum(1/(np.arange(pocet_period)+1))

vysledny_signal = np.mean(periody, axis=0)

plt.plot(vysledny_signal, label='Výsledný signál')
plt.plot(puvodni_signal, label='Původní signál')
plt.legend()
plt.xlabel('Vzorky')
plt.ylabel('Hodnota')
plt.title('Kumulační technika s rostoucím šumem')
plt.show()


