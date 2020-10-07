## Run the workflow on a local machine
```
popper run -f workflows/local/.popper.yml
```

## Run the workflow on Kubernetes
1. Get access to a Kubernetes cluster if you don't already have access to one.

2. Execute the workflow,
```
popper run -f workflows/kubernetes/.popper.yml -c workflows/kubernetes/config.yml
```

## Run the workflow on Slurm

1. Login into the Slurm cluster and Clone the repository in the shared directory.

2. Execute the workflow,
```
popper run -f workflows/slurm/.popper.yml -c workflows/slurm/config.yml
```
