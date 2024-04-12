import psutil
import pyautogui
import random

# get CPU cores usage to use as a seed for random number generator
cores_prctg = psutil.cpu_percent(interval=1, percpu=True)

# get mouse position
x,y = pyautogui.position()

# calculate seed
my_seed_x = x
my_seed_y = y
for prctg in cores_prctg:
    my_seed_x *= prctg
    my_seed_y *= prctg

my_seed = abs(my_seed_x - my_seed_y)

# set seed for random number generator
random.seed(my_seed)

