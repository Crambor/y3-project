import matplotlib.pyplot as plt

replicas = list(range(1, 11))
baremetal_times = [
    102.58,
    51.38,
    35.24,
    26.2,
    21.17,
    18.17,
    15.16,
    14.1,
    12.13,
    11.12,
]
kubernetes_times = [
    102.13,
    51.07,
    35.05,
    26.04,
    21.03,
    17.04,
    15.04,
    13.09,
    13.09,
    13.09,
]

baremetal_scaling_factors = [baremetal_times[0] / time for time in baremetal_times]
kubernetes_scaling_factors = [baremetal_times[0] / time for time in kubernetes_times]

plt.figure(figsize=(10, 6))
plt.plot(replicas, baremetal_scaling_factors, marker='o', linestyle='-', color='blue', label='Baremetal')
plt.plot(replicas, kubernetes_scaling_factors, marker='o', linestyle='-', color='red', label='Kubernetes')
plt.plot(replicas, replicas, marker='o', linestyle='-', color='orange', label='Linear Scaling')

plt.title('Scaling Efficiency Relative to Single Replica Performance - 1s Sleep Test')
plt.xlabel('Number of Replicas')
plt.ylabel('Scaling Factor (Time for 1 Replica / Time for N Replicas)')
plt.legend()
plt.grid(True)
plt.show()

