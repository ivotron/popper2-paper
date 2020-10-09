# CANOPIE paper artifacts

Repository for the submission:

> Jayjeet Chakraborty, Carlos Maltzahn and Ivo Jimenez. _Enabling 
> Seamless Execution of Computational and Data Science Workflows on 
> HPC and Cloud with the Popper Container-native Automation Engine_.

The repository is structured as follows:

* `workflows/`. Contains the workflow used in the "Case Study" section 
  of the paper. This workflow trains a model for the MNIST dataset, 
  and can be executed locally or on Kubernetes or Slurm clusters.

* `paper/`. Contains the paper and the static assets used in the paper 
  along with a Popper workflow to plot the results and build the paper 
  after running an experiment.

* `results/`. The location where result files get generated after 
  running the experiment workflows. It also contains a Jupyter 
  notebook to plot the results which is executed by the workflow here.

## Installing Popper
To install Popper, run the following in your terminal:

```bash
python3 -m venv venv
source venv/bin/activate
pip install popper
```

## Building the paper

```bash
popper run -f paper/.popper.yml
```

## Running the workflow

### Local

```bash
popper run -f workflows/mnist/.popper.yml
```

### Kubernetes

Get access to a Kubernetes cluster if you don't already have access to 
one. Popper assumes that a [`kubectl` configuration](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file is 
available.

To execute the workflow:

```bash
popper run -f workflows/mnist/.popper.yml -c workflows/mnist/config_k8s.yml
```

### Slurm

Singularity is required on the Slurm nodes. After logging into the 
Slurm cluster, installing popper and cloning this repository, execute:

Execute the workflow,

```bash
popper run -f workflows/mnist/.popper.yml -c workflows/mnist/config_slurm.yml
```
