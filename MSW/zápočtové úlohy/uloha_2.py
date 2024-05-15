import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

def linear_approx(x: list, y: list):
    xnadruhou = []
    for e in x:
        e = e**2
        xnadruhou.append(e)
    xkraty = []
    for e in range(len(x)):
        i = x[e] * y[e]
        xkraty.append(i)

    suma_x = sum(x)
    suma_y = sum(y)
    suma_xnadruhou = sum(xnadruhou)
    suma_xkraty = sum(xkraty)

    n = len(x)

    D = np.array([[suma_x,suma_xnadruhou], [n,suma_x]])

    D_a = np.array([[suma_x,suma_xkraty], [n,suma_y]])
    D_b = np.array([[suma_xkraty,suma_xnadruhou], [suma_y,suma_x]])

    a = np.linalg.det(D_a) / np.linalg.det(D)
    b = np.linalg.det(D_b) / np.linalg.det(D)

    res_x = np.linspace(min(x),max(x),50)
    res_y = [a*xi + b for xi in res_x]

    return res_x, res_y



data = pd.read_csv("Orange Quality Data.csv")



x,y = linear_approx(data["Size (cm)"], data["Weight (g)"])
plt.plot(x, y, "r-")
plt.plot(data["Size (cm)"], data["Weight (g)"], "g.")
plt.xlabel("Size (cm)")
plt.ylabel("Weight (g)")
plt.legend(["Approximation", "Data"])
plt.title("Orange Size vs. Weight")
plt.show()


x,y = linear_approx(data["HarvestTime (days)"], data["Size (cm)"])
plt.plot(x, y, "r-")
plt.plot(data["HarvestTime (days)"], data["Size (cm)"], "g.")
plt.xlabel("HarvestTime (days)")
plt.ylabel("Size (cm)")
plt.legend(["Approximation", "Data"])
plt.title("Harvest Time vs. Size")
plt.show()



x,y = linear_approx(data["HarvestTime (days)"], data["Weight (g)"])
plt.plot(x, y, "r-")
plt.plot(data["HarvestTime (days)"], data["Weight (g)"], "g.")
plt.xlabel("HarvestTime (days)")
plt.ylabel("Weight (g)")
plt.legend(["Approximation", "Data"])
plt.title("Harvest Time vs. Weight")
plt.show()


x,y = linear_approx(data["Weight (g)"], data["Brix (Sweetness)"])
plt.plot(x, y, "r-")
plt.plot(data["Weight (g)"], data["Brix (Sweetness)"], "g.")
plt.xlabel("Weight (g)")
plt.ylabel("Brix (Sweetness)")
plt.legend(["Approximation", "Data"])
plt.title("Weight vs. Sweetness")
plt.show()

x,y = linear_approx(data["Size (cm)"], data["Quality (1-5)"])
plt.plot(x, y, "r-")
plt.plot(data["Size (cm)"], data["Quality (1-5)"], "g.")
plt.xlabel("Size (cm)")
plt.ylabel("Quality (1-5)")
plt.legend(["Approximation", "Data"])
plt.title("Size vs. Quality")
plt.show()

