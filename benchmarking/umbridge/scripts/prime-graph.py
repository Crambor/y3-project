import matplotlib.pyplot as plt

replicas = list(range(1, 11))
baremetal_times = [104.71, 52.67, 35.85, 27.59, 22.88, 19.06, 16.79, 14.58, 14.22, 14.02]
kubernetes_times = [197.04, 98.52, 65.71, 49.92, 40.39, 33.91, 29.61, 25.69, 25.86, 25.82]

baremetal_scaling_factors = [baremetal_times[0] / time for time in baremetal_times]
kubernetes_scaling_factors = [baremetal_times[0] / time for time in kubernetes_times]

plt.figure(figsize=(10, 6))
plt.plot(replicas, baremetal_scaling_factors, marker='o', linestyle='-', color='blue', label='Baremetal')
plt.plot(replicas, kubernetes_scaling_factors, marker='o', linestyle='-', color='red', label='Kubernetes')
plt.plot(replicas, replicas, marker='o', linestyle='-', color='orange', label='Linear Scaling')

plt.title('Scaling Efficiency Relative to Single Replica Performance - Prime Number Generation')
plt.xlabel('Number of Replicas')
plt.ylabel('Scaling Factor (Time for 1 Replica / Time for N Replicas)')
plt.legend()
plt.grid(True)
plt.show()

