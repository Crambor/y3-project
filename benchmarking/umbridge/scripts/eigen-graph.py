import matplotlib.pyplot as plt

replicas = list(range(1, 11))
baremetal_times = [142.67, 75.65, 56.11, 48.57, 46.48, 45.08, 36.5, 29.56, 27.09, 27.01]
kubernetes_times = [
    148.05,
    75.51,
    53.14,
    41.74,
    36.83,
    31.73,
    31.58,
    32.25,
    33.08,
    36.41,
]

baremetal_scaling_factors = [baremetal_times[0] / time for time in baremetal_times]
kubernetes_scaling_factors = [baremetal_times[0] / time for time in kubernetes_times]

plt.figure(figsize=(10, 6))
plt.plot(replicas, baremetal_scaling_factors, marker='o', linestyle='-', color='blue', label='Baremetal')
plt.plot(replicas, kubernetes_scaling_factors, marker='o', linestyle='-', color='red', label='Kubernetes')
plt.plot(replicas, replicas, marker='o', linestyle='-', color='orange', label='Linear Scaling')

plt.title('Scaling Efficiency Relative to Single Replica Performance - Eigenvalue Generation')
plt.xlabel('Number of Replicas')
plt.ylabel('Scaling Factor (Time for 1 Replica / Time for N Replicas)')
plt.legend()
plt.grid(True)
plt.show()

