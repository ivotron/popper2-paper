# CANOPIE paper artifacts

Repository for the submission:

> Jayjeet Chakraborty, Carlos Maltzahn and Ivo Jimenez. _Enabling 
> Seamless Execution of Computational and Data Science Workflows on 
> HPC and Cloud with the Popper Container-native Automation Engine_.

The repository is structured as follows:

* `workflow/`. Contains the workflow used in the "Case Study" section 
  of the paper. This workflow trains a model for the MNIST dataset, 
  and can be executed locally or on Kubernetes or Slurm clusters.

* `paper/`. Contains the paper and the static assets used in the paper 
  along with a Popper workflow to plot the results and build the paper 
  after running an experiment.

* `results/`. The location where result files get generated after 
  running the experiment workflows. It also contains a Jupyter 
  notebook to plot the results which is executed by the workflow here.

## Running the workflow

### Local

```bash
popper run -f workflows/local/.popper.yml
```

### Kubernetes

Get access to a Kubernetes cluster if you don't already have access to 
one. Popper assumes that a [`kubectl` configuration]() file is 
available.

To execute the workflow:

```bash
popper run -f workflows/kubernetes/.popper.yml -c workflows/kubernetes/config.yml
```

### Slurm

Singularity is required on the Slurm nodes. After logging into the 
Slurm cluster, installing popper and cloning this repository, execute:

Execute the workflow,

```bash
popper run -f workflows/slurm/.popper.yml -c workflows/slurm/config.yml
```
