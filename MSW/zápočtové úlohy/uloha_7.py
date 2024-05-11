import random
import matplotlib.pyplot as plt

class CustomerQueueSimulation:
    def __init__(self, arrival_rate, service_rate, num_iterations, max_time):
        self.arrival_rate = arrival_rate
        self.service_rate = service_rate
        self.num_iterations = num_iterations
        self.max_time = max_time

    def simulate(self):
        queue_sizes = []

        for _ in range(self.num_iterations):
            time = 0
            queue_size = 0

            while time < self.max_time:
                inter_arrival_time = random.expovariate(self.arrival_rate)
                service_time = random.expovariate(self.service_rate)

                if inter_arrival_time < service_time:
                    time += inter_arrival_time
                    queue_size += 1
                else:
                    time += service_time
                    queue_size = max(0, queue_size - 1)

                queue_sizes.append(queue_size)


        return queue_sizes

# Parameters
arrival_rate = 0.5  # Mean inter-arrival time (customers arrivals per minute)
service_rate = 1  # Mean service time (services done per minute)
num_iterations = 1 # Number of simulations
max_time = 2500  # Maximum time to simulate (minutes in opening hours)

# Create a simulation instance
simulation = CustomerQueueSimulation(arrival_rate, service_rate, num_iterations, max_time)

# Run the simulation
queue_sizes = simulation.simulate()

# Plot the queue size over time
plt.plot(queue_sizes)
plt.xlabel('Time')
plt.ylabel('Queue Size')
plt.title('Customer Queue Simulation')
plt.show()