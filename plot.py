import os
import matplotlib.pyplot as plt


runs = ["1", "2", "3", "4", "5"]
time_local = [4035, 4023, 4036, 4021, 4056]
time_k8s = [1194, 965, 1021, 894, 934]
time_slurm = [234, 262, 253, 201, 224]

plt.xlabel('Runs')
plt.ylabel('Training Duration (seconds)')
plt.plot(runs, time_local, markersize=10, linewidth=3.0, label='Local Machine')
plt.plot(runs, time_k8s, markersize=10, linewidth=3.0, label='Single GPU in Kubernetes')
plt.plot(runs, time_slurm, markersize=10, linewidth=3.0, label='Triple GPU in Slurm')
plt.legend()
plt.savefig('./figures/plot.png', dpi=300, bbox_inches='tight')
