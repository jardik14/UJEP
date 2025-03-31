import numpy as np
import skfuzzy as fuzz
from skfuzzy import control as ctrl
import matplotlib.pyplot as plt

# Definice vstupních proměnných
room_temp = ctrl.Antecedent(np.arange(0, 41, 1), 'room_temp')
target_temp = ctrl.Antecedent(np.arange(0, 41, 1), 'target_temp')

# Definice výstupní proměnné
ac_command = ctrl.Consequent(np.arange(-5, 6, 1), 'ac_command')

# Gaussovské příslušnostní funkce
room_temp['cold'] = fuzz.gaussmf(room_temp.universe, 5, 5)
room_temp['cool'] = fuzz.gaussmf(room_temp.universe, 15, 5)
room_temp['warm'] = fuzz.gaussmf(room_temp.universe, 25, 5)
room_temp['hot'] = fuzz.gaussmf(room_temp.universe, 35, 5)
room_temp.view()

target_temp['cold'] = fuzz.gaussmf(target_temp.universe, 5, 5)
target_temp['cool'] = fuzz.gaussmf(target_temp.universe, 15, 5)
target_temp['warm'] = fuzz.gaussmf(target_temp.universe, 25, 5)
target_temp['hot'] = fuzz.gaussmf(target_temp.universe, 35, 5)
target_temp.view()

ac_command['cooling'] = fuzz.gaussmf(ac_command.universe, -5, 2)
ac_command['no_change'] = fuzz.gaussmf(ac_command.universe, 0, 1)
ac_command['heating'] = fuzz.gaussmf(ac_command.universe, 5, 2)
ac_command.view()

# Definice fuzzy pravidel
rule1 = ctrl.Rule(room_temp['cold'] & target_temp['hot'], ac_command['heating'])
rule2 = ctrl.Rule(room_temp['hot'] & target_temp['cold'], ac_command['cooling'])
rule3 = ctrl.Rule(room_temp['cool'] & target_temp['warm'], ac_command['heating'])
rule4 = ctrl.Rule(room_temp['warm'] & target_temp['cool'], ac_command['cooling'])
rule5 = ctrl.Rule(room_temp['warm'] & target_temp['warm'], ac_command['no_change'])
rule6 = ctrl.Rule(room_temp['hot'] & target_temp['hot'], ac_command['no_change'])
rule7 = ctrl.Rule(room_temp['cold'] & target_temp['cold'], ac_command['no_change'])

# Vytvoření a simulace řídicího systému
ac_ctrl = ctrl.ControlSystem([rule1, rule2, rule3, rule4, rule5, rule6, rule7])
ac_simulation = ctrl.ControlSystemSimulation(ac_ctrl)

# Testovací vstupní hodnoty
ac_simulation.input['room_temp'] = 30
ac_simulation.input['target_temp'] = 20
ac_simulation.compute()
print(f"Výstupní hodnota: {ac_simulation.output['ac_command']:.2f}")
ac_command.view(sim=ac_simulation)

# Vizualizace výstupu
room_vals, target_vals = np.meshgrid(np.arange(0, 41, 1), np.arange(0, 41, 1))
output_vals = np.zeros_like(room_vals, dtype=float)

for i in range(room_vals.shape[0]):
    for j in range(room_vals.shape[1]):
        ac_simulation.input['room_temp'] = room_vals[i, j]
        ac_simulation.input['target_temp'] = target_vals[i, j]
        ac_simulation.compute()
        output_vals[i, j] = ac_simulation.output['ac_command']

fig = plt.figure(figsize=(10, 7))
ax = fig.add_subplot(111, projection='3d')
ax.plot_surface(room_vals, target_vals, output_vals, cmap='coolwarm')
ax.set_title('AC Command Based on Room and Target Temperature')
ax.set_xlabel('Room Temperature (°C)')
ax.set_ylabel('Target Temperature (°C)')
ax.set_zlabel('AC Command')
plt.savefig("ac_command.png")
plt.show()
