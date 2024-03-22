import matplotlib.pyplot as plt
import pandas as pd

data = pd.read_csv("Orange Quality Data.csv")


plt.plot(data["Size (cm)"], data["Weight (g)"], "r.")
plt.xlabel("Size (cm)")
plt.ylabel("Weight (g)")
plt.title("Orange Size vs. Weight")
plt.show()

plt.plot(data["HarvestTime (days)"], data["Size (cm)"], "b.")
plt.xlabel("HarvestTime (days)")
plt.ylabel("Size (cm)")
plt.title("Harvest Time vs. Size")
plt.show()

plt.plot(data["HarvestTime (days)"], data["Weight (g)"], "g.")
plt.xlabel("HarvestTime (days)")
plt.ylabel("Weight (g)")
plt.title("Harvest Time vs. Weight")
plt.show()

plt.plot(data["Weight (g)"], data["Brix (Sweetness)"], "g.")
plt.xlabel("Weight (g)")
plt.ylabel("Brix (Sweetness)")
plt.title("Weight vs. Sweetness")
plt.show()
