---
title: "Enabling seamless execution of containerized workflows on HPC and Cloud using Popper"
author:
- name: Jayjeet Chakraborty, Carlos Maltzahn, Ivo Jimenez
  affiliation: UC Santa Cruz

abstract: |
   The problem of reproducibility and replication in scientific research is quite prevalent to date. 
   Researchers working in fields of computational science often find it difficult to reproduce experiments from artifacts like code, data, diagrams, and results which are left behind by the previous researchers. 
   The code developed on one machine often fails to run on other machines due to differences in hardware architecture, OS, software dependencies, among others. 
   This is accompanied by the difficulty in understanding how artifacts are organized, as well as in using them in the correct order. 
   Software containers (also known as Linux containers) can be used to address some of these problems, and thus researchers and developers have built scientific workflow engines that execute the steps of a workflow in separate containers. 
   Existing container-native workflow engines assume the availability of infrastructure deployed in the cloud or HPC centers. 
   In this paper, we present Popper, a container-native workflow engine that does not assume the presence of a Kubernetes cluster or any service other than a container engine such as Docker or Podman. 
   We introduce the design and architecture of Popper and describe how it abstracts away the complexity of multiple container engines and resource managers, enabling users to focus only on writing workflow logic. 
   With Popper, researchers can build and validate workflows easily in almost any environment of their choice including local machines, Slurm based HPC clusters, CI services, or Kubernetes based cloud computing environments. 
   To exemplify the suitability of this workflow engine, we present three case studies where we take examples from machine learning and high-performance computing and turn them into Popper workflows.
---

# Introduction {#sec:intro}

<!-- defining the problem of reproducibility in computational science -->

Researchers working in various domains related to computational and data-intensive science upload experimental artifacts like code, figures, datasets, and configuration files, to open-access repositories like Zenodo [@_zenodo_], Figshare [@_figshare_], or GitHub [@github]. 
According to [@stagge2019assessing], approximately 1% of the artifacts available online are fully reproducible and 0.6% of them are partially reproducible. 
A 2016 study by Nature found that from a group of 1576 scientists, around 70% of them failed to reproduce each other's experiments [@baker2016reproducibility].
This problem occurs mostly due to the lack of proper documentation, missing artifacts, or encountering broken software dependencies.
This results in other researchers wasting time trying to figure out how to reproduce those experiments from the archived artifacts, ultimately making this process inefficient, cumbersome, and error prone [@sep-scientific-reproducibility].

<!-- discuss previous work -->

Numerous existing research has tried to address the problem of reproducibility [@goodman2016does] by different means; for example, logging and tracing system calls, using workflow engines, using correctly provisioned shared and public testbeds, by recording and replaying changes from a stable initial state, among many others [@reproducibility2018acm].
These approaches have led to the development of various tools and frameworks to address these problems of reproducibility [@piccolo2016tools; @peng2011reproducible], 
with scientific workflow engines being a predominant one [@stevens2013automated; @banati2015minimal; @qasha2016framework]. A workflow engine organizes the steps of a scientific experiment as the nodes of a directed acyclic graph (DAG) and executes them in the correct order [@albrecht2012makeflow].
Nextflow [@ditommaso_nextflow_2017], Pegasus [@deelman_pegasus_2004] and Taverna [@oinn_taverna_2004] are examples of widely used scientific workflow engines.
But some phenomena like unavailability of third-party services, missing example input data, changes in the execution environment, insufficient documentation of workflows make it difficult for scientists to reuse workflows, resulting in _workflow decay_ [@workflow_decay].

<!-- attempts to solves using containers and what problem still remains -->

One of the main reasons behind _workflow decay_ is the difficulty in reproducing the environment where a workflow is developed and originally executed [@meng2017facilitating]. 
Virtual machines (VM's) can be used to address this problem, as its isolation guarantees make it suitable for running steps or the entirety of a workflow inside a separate VM [@howe2012virtual; @virtandnestedvirt2012].
A VM is typically associated with large resource utilization (e.g. long start times and high memory usage), making OS-level virtualization technologies a better-suited tool for reproducing computational environments with fewer overheads [@barik2016performance; @sharma2016containers]. 
Although software (Linux) containers are a relatively old technology [@menage_adding_2007], it was not until recently, with the rise of Docker, that they entered mainstream territory [@bernstein_containers_2014]. 

Docker has been a popular container runtime for a long time, with other container runtimes such as Singularity [@kurtzer_singularity_2017], Rkt [@rktcommunity_rkt_2019], Charliecloud [@priedhorsky_charliecloud_2017], and Podman [@podmancommunity_containers_2019] having emerged. 
With containers, the container-native software development paradigm emerged, which promotes the building, testing, and deployment of software in containers, simultaneously giving rise to the practice of running scientific experiments inside containers to make them platform independent and reproducible [@jimenez:woc15; @stubbs2016endofday; @zheng_integrating_2015]. 
Differences among container engines stem from the need to serve distinct use cases, manifesting in user experience (UX) differences such as those found in their command-line interfaces (CLIs), container image formats; security requirement and environment differences such as Podman for enhanced security and Singularity for use in HPC, etc.
In practice, for users attempting to make use of container technology, these differences can be overwhelming, especially if they are only familiar with the basic concepts of how containers work. 
Based on our analysis of the container tooling landscape, we found that there is an absence of tools for allowing users to work with containers in an engine-agnostic way. 
It has also been found that as scientific workflows become increasingly complex, continuous validation of the workflows which is critical to ensuring good reproducibility, becomes difficult [@deelman2018future; @cohen2017scientific].

Currently, different container-based workflow engines are available but all of them assume the presence of a fully provisioned Kubernetes cluster [@kubernetes_google].
The presence of a Kubernetes cluster or a cloud computing environment reduces the likelihood of researchers to adopt container technology for reproducing any experiment since it is often costly [@rodriguez2020container] to get access to one and this, in turn, makes reproducibility complex. 
It would be more convenient for researchers if workflow engines provided the flexibility of running workflows in a wide range of computing environments including those that are readily available for them to use.

<!-- our contributions -->

Popper [@systemslabpopper] is a light-weight workflow execution engine that allows users to follow the container-native paradigm for building reproducible workflows from archived experimental artifacts. 
This paper makes the following contributions:

1. The design and architecture of a container-native workflow engine that abstracts multiple resource managers and container engines giving users the ability to focus only on Dockerfiles, i.e. software dependencies and workflow logic, i.e. correct order of execution, and ignore the runtime specific details.

2. Popper, an implementation of the above design that allows running workflows inside containers in different computing environments like local machines, Kubernetes clusters, or HPC [@yang2005high] environments.

3. Three case studies on how Popper can be used to quickly reproduce complex workflows in different computing environments. 
   We show how an entire Machine Learning workflow can be run on a local machine during development and how it can be reproduced in a Kubernetes cluster with GPUs to scale up and collect results. 
   We also show how an HPC workflow developed on the local machine can be reproduced easily in a Slurm [@slurm] cluster.

# Popper {#sec:popper}

In this section, we describe the motivation behind Popper, provide background, and then introduce its architectural design and implementation.

## Motivation

Let us take a relatively simple scenario where users have a list of single-purpose tasks in the form of scripts and they want to automate running them in containers in some sequence.
To accomplish this goal of running a list of containerized tasks using existing workflow engines, users need to learn a specific workflow language, deploy a workflow engine service, and learn to execute workflows on that service.
These tasks may not be always trivial to accomplish if we assume the only thing users should care about is writing experimentation scripts and running them inside containers.
Assume we have three scripts `download_dataset.py`, `verify_dataset.sh`, and `run_training.sh` to download a dataset, verify its contents and run a computational step.
In practice, when developers work following the container-native paradigm they end up interactively executing multiple Docker commands to build containers, compile code, test applications, or deploy software.
Keeping track of which commands were executed, in which order, and which flags were passed to each, can quickly become unmanageable, difficult to document, error prone, and hard to reproduce.

The goal of Popper is to bring order to this chaotic scenario by providing a framework for clearly and explicitly defining container-native tasks.
Running workflows on dissimilar environments like Kubernetes and Slurm incurs multiple operational overheads like adopting environment-specific commands, writing job scripts and definitions, dealing with different image formats like the flat image format of singularity, etc. which are peculiar to a specific computing environment.
For example, running a containerized step on Kubernetes would require writing Pod and Volume specifications and creating them using a Kubernetes client. 
Likewise, running an MPI workload inside a Singularity container on Slurm would require creating job scripts and starting the job with `sbatch`.
Popper mitigates these environment-specific overheads by abstracting the different implementation details and provides a uniform interface that allows users to write workflows once and reuse them on different environments with tweaks to the configuration file.

## Background

In this subsection, we provide background on the different tools and technologies that Popper leverages in order to provide the ability of running engine- and resource manager-agnostic container-native workflows.

### Docker

Docker is an OS-level virtualization technology that was released in early 2013.
It uses various Linux kernel features like namespaces and cgroups to segregate processes so that they can run independently.
It provides state of the art isolation guarantees and makes it easy to build, deploy, and run applications using containers following the OCI (Open Container Initiative) [@oci] specifications. 
However, it was not designed for use in multi-user HPC environments and also has significant security issues [@yasrab2018mitigating], which might enable a user inside a Docker container to have root access to the host system's network and filesystem, thus making it unsuitable for use in HPC systems. 
Also, Docker uses cgroups [@rosen2013resource] to isolate containers, which conflicts with the Slurm scheduler since it also uses cgroups to allocate resources to jobs and enforce limits [@brayford2019deploying].

### Singularity

Singularity is a daemon-less scientific container technology built by LBNL (Lawrence Berkley National Laboratory) and first released in 2016. 
It is designed to be simple, fast, secure, and provides containerized solutions for HPC systems supporting several HPC components such as resource managers, job schedulers and contains native MPI [@mpi1993] features. 
One of the main goals of Singularity is to bring container technology and reproducibility to the High-Performance Computing world. 
The key feature that differentiates it from Docker is that it can be used in non-privileged computing environments like the compute nodes of HPC clusters, without any modifications to the software. 
It also provides an abstraction that enables using container images from different image registries interchangeably like Docker Hub, Singularity Hub, and Sylabs Cloud.
These features make Singularity increasingly useful in areas of Machine learning, Deep learning, and other data-intensive applications where the workloads benefit from HPC systems.

### Slurm

Slurm is an open-source cluster resource management and job scheduling system developed by LLNL (Lawrence Livermore National Laboratory) for Linux clusters ranging from a few nodes to thousands of nodes. 
It is simple, scalable, portable, fault-tolerant, secure, and interconnect agnostic. 
It is used as a workload manager by almost 60% of the world's top 500 supercomputers [@ibrahim2017algorithms]. 
Slurm provides a plugin-based mechanism for simplifying its use across different computing infrastructures.
It enables both exclusive and non-exclusive allocation of resources like compute nodes to the users. 
It provides a framework for starting, executing, and monitoring parallel jobs on a set of allocated nodes and arbitrate conflicting requests for resources by managing a queue of pending work. 
Slurm runs as a daemon in the compute nodes and also provides an easy to use CLI interface.

### Kubernetes

Kubernetes is a production-grade open-source container orchestration system written in Golang that automates many of the manual processes involved in deploying, scaling, and managing of containerized applications across a cluster of hosts. 
A cluster can span hosts across public, private, or hybrid clouds. 
This makes Kubernetes an ideal platform for hosting cloud-native applications. 
Kubernetes supports a wide range of container runtimes including Docker, Rkt, and Podman. 
It was originally developed and designed by engineers at Google and it is hosted and maintained by the CNCF (Cloud Native Computing Foundation). 
Many cloud providers like GCP, AWS, and Azure provide a completely managed and secure hosted Kubernetes platform.

### Continuous Integration

Continuous Integration is a software development paradigm where developers commit code into a shared repository frequently, ideally several times a day.
Each integration is verified by automated builds and tests of the corresponding commits.
This helps in detecting errors and anomalies quickly and shortens the debugging time [@virmani2015understanding].
Several hosted CI services like Travis, Circle, and Jenkins make continuous integration and continuous validation easily accessible.

## Workflow Definition Language

YAML [@ben2009yaml] is a human-readable data-serialization language. 
It is commonly used in writing configuration files and in applications where data is stored or transmitted. 
Due to its simplicity and wide adoption [@yaml_wide_adoption], we chose YAML for defining Popper workflows and for specifying the configuration for the execution engine. 
An example Popper workflow is shown in @Lst:wf-example which downloads a dataset in CSV format, runs statistical functions on the data, and validates the results.

```{#lst:wf-example .yaml caption="A three-step workflow."}
steps:
# download CSV file with data on global CO2 emissions
- id: download
  uses: docker://byrnedo/alpine-curl:0.1.8
  args: [-LO, https://git.io/JUcRU]

# obtain the transpose of the global CO2 emissions table
- id: get-transpose
  uses: docker://getpopper/csvtool:2.4
  args: [transpose, global.csv, -o, global_transposed.csv]
```

![DOT diagram of a Popper workflow DAG](./figures/wf.pdf){#fig:casestudy .center height=35%}

A Popper workflow consists of a series of syntactical components called steps, where each step represents a node in the workflow DAG, with a `uses` attribute specifying the required container image. 
The `uses` attribute can reference Docker images hosted in container image registries; filesystem paths for locally defined container images (Dockerfiles); or publicly accessible GitHub repositories that contain Dockerfiles. 
The commands or scripts that need to be executed in a container can be defined by the `args` and `runs` attributes. 
Secrets and environment variables needed by a step can be specified by the `secrets` and `env` attributes respectively for making them available inside the container associated with a step.
The steps in a workflow are executed sequentially in the order in which they are defined.

## Workflow Execution Engine

The Popper workflow execution engine is composed of several components that talk to each other during workflow execution.
The vital architectural components of the system are described in detail throughout this section.
The architecture of the Popper workflow engine is shown in @Fig:arch;

### Command Line Interface (CLI)

Besides allowing users to communicate with the workflow runner, the CLI allows visualizing workflows by generating DOT diagrams [@dot] like the one shown in @Fig:casestudy;
generates configuration files for continuous integration systems such as Travis or Jenkins, so that users can continuously validate their workflows;
provides dynamic workflow variable substitution capabilities, among others.

### Workflow Definition and Configuration Parsers

The workflow file and the configuration file are parsed by their respective parser plugins at the initial stages of the workflow execution.
The parsers are responsible for reading and parsing the YAML files into an internal format;
running syntactic and semantic validation checks;
normalizing the various attributes and generating a workflow DAG.
The workflow parser has a pluggable architecture that allows adding support to other workflow languages.

### Workflow Runner

The Workflow runner is in charge of taking a parsed workflow representation as input and executing it.
It also downloads actions referenced by the steps in a workflow, checks the presence of secrets that are required by a workflow, and routes the execution of a step to the configured container engine through the requested resource manager. 
The runner also maintains a cache directory to optimize multiple aspects of execution such as avoid cloning repositories if they have been already cloned previously. 
Thus, this component orchestrates the entire workflow execution process.

### Resource Manager and Container Engine API

Popper supports running containers in both single-node and multi-node cluster environments. 
Each of these different environments has a very specific job and process scheduling policies. 
The resource manager API is a pluggable interface that allows the creation of plugins (also referred to as runners) for distinct job schedulers (e.g. Slurm, SGE, HTCondor) and cluster managers (e.g. Kubernetes, Mesos, YARN). 
Currently, plugins for Slurm and Kubernetes exist, as well as the default local runner that executes workflows on the local machine where Popper is executed.
Resource manager plugins provide abstractions for different container engines which allows a particular resource manager to support new container engines through plugins.
For example, in the case of Slurm, it currently supports running Docker and Singularity containers but other container engines can also be integrated like Charliecloud [@charliecloud] and Pyxis [@pyxis].
The container engine plugins abstract generic operations that all engines support such as creating an image from a `Dockerfile`;
downloading images from a registry and converting them to their internal format;
and container-level operations such as creation, deletion, and renaming.
Currently, there are plugins for Docker, Podman and Singularity, with others planned by the Popper community.

The behavior of a resource manager and a container engine can be customized by passing specific configuration through the configuration file.
This enables the users to take advantage of engine and resource manager specific features in a transparent way.
In the presence of a `Dockerfile` and a workflow file, a workflow can be reproduced easily in different computing environments only by tweaking the configuration file.
For example, a workflow developed on the local machine can be run on an HPC cluster using Singularity containers by specifying information like the available MPI library, the number of nodes and CPUs to run on, etc. in the configuration file.
The configuration file can be passed through the CLI interface and can be shared among different workflows.
It can either be created by users or provided by system administrators.

![Architecture of the Popper workflow engine](./figures/architecture_med.pdf){#fig:arch}

## Continuous Integration

Popper allows users to continuously validate their workflows by allowing them to export workflows as CI pipelines for different continuous integration services like Travis, Circle, or Jenkins.
The Popper workflows that are written and run locally can be seamlessly run on CI services and vice versa, allowing the development environment to be consistent on both local and CI.
To run a Popper workflow on a CI service, it is required to generate a CI configuration file using the `ci` subcommand of the Popper CLI tool, push the project to GitHub and enable the repository on the CI provider.
Using CI to run Popper workflows enhances the reproducibility guarantees as continuous validation helps to keep a check on various breaking changes like outdated dependencies, broken links, or deleted Docker images.
Another benefit of using CI to run Popper workflows is that even without changes, jobs can be configured so that they run periodically (e.g. once a week), to ensure that they are in a healthy state.

# Case Study {#sec:casestudy}

In this section, we present three case studies demonstrating how the Popper workflow engine allows reproducing and scaling workflows in different computing environments.
These case studies aim to emphasize on how Popper can help in mitigating these reproducibility issues and make life easier for researchers and developers.
For these case studies, we built an image classification workflow that runs the training using Keras [@gulli2017deep] over the MNIST [@mnistdataset] dataset having 3 steps; download; verify; and train.
The workflow used for the case studies is depicted in @Lst:casestudy. 
The code that the workflow references can be found here [^code].

```{#lst:casestudy .yaml caption="Workflow used in the case studies."}
steps:
- id: download-dataset
  uses: docker://gw000/keras
  args: ["python", "./scripts/download_dataset.py"]

- id: verify-dataset
  uses: docker://alpine:3.9.5
  args: ["./scripts/verify_dataset.sh"]

- id: run-training
  uses: docker://gw000/keras
  args: ["./scripts/run_training.sh"]
  env:
    NUM_EPOCHS: '10'
    BATCH_SIZE: '128'
```

The `download` step downloads the MNIST dataset in the workspace. 
The `verify` step verifies the downloaded archives against precomputed checksums.
The `train` step then starts training the model on this downloaded dataset and records the duration of the training.
The download and train steps use a Keras docker image and the verify step uses a lightweight alpine image.
Although a single Docker image can be used in all the steps of a workflow, we recommend using images specific to the purpose of a step otherwise it could make dependency management complex, hence defeating the purpose of containers.

The general paradigm for building reproducible workflows with Popper usually consists of the following steps:
1. Thinking of the logical steps of the workflow.
2. Finding the relevant software packages required for the implementation of these steps.
  a. Finding images containing the required software from remote image registries like DockerHub, Quay.io, Google Container Registry, etc.
  b. If a prebuilt image is not available, a `Dockerfile` can be used to build an image manually which is a file containing specifications for building Docker images.
3. Running the workflow and refining it.

[^code]: <https://github.com/ivotron/popper-canopie-paper>

### Workflow execution on the local machine

Popper aids researchers in writing, testing, and debugging workflows on their local development machines.
Researchers can iterate quickly by making changes and executing the `popper run` command to see the effect of their changes immediately.
We used an Apple Macbook Pro Laptop with a 2.4GHz quad-core Intel Core i5 64-bit processor and 8 Gb LPDDR3 RAM for this case study.
The image classification workflow was built and run on the MNIST dataset [@deng2012mnist] using the Docker container engine.
On single node machines, Popper leaves the job of scheduling the containerized steps to the host machines OS.
We ran the workflow 5 times with an overfitting patience of 5 on the laptop's CPU.
The results obtained over 5 executions have been shown in @Fig:casestudies.

To achieve lower training durations, the training should ideally be done on GPUs in the cloud which in turn require these workflows to be easily portable to multi-node cloud environments.
In the next section, we will look at how we ran the workflow developed on the local machine efficiently on the Kubernetes using Popper.

### Workflow execution in the Cloud using Kubernetes

In this section, we discuss how we reduced the training duration in the above workflow by reproducing it on a GPU enabled Kubernetes cluster.
On Kubernetes clusters, steps of a Popper workflow run in separate pods that can get scheduled on any node of the cluster in a separate namespace.
Popper first builds the images required by the workflow and pushes them to an online image registry like DockerHub, Google Container Registry, etc.
Then a `PersistentVolumeClaim` is created to claim persistent storage space from a shared filesystem like NFS [@sandberg1985design] for the different step pods to share.
After the pod is created, the workflow context consisting of the scripts, configs, etc. is copied into the shared volume mounted inside the pod and executed.
Although any Kubernetes cluster can be used, for this case study, we used a 3-node Kubernetes cluster on Cloudlab [@CloudLab] each with an NVIDIA 12GB PCI P100 GPU.
The training pod used the single GPU of the node on which it was scheduled.
Reproducing the workflow developed on the local machine in the Kubernetes cluster only requires changing the resource manager specifications in the configuration file like specifying Kubernetes as the requested resource manager, specifying the `PersistentVolumeClaim` size, the image registry credentials, etc.
The training was configured with an overfitting patience of 5 and was allowed to run till it overfits similar to what was done for the local machine case study.

As we can see from @Fig:casestudies, the average training duration was almost 1/4th of what it took to train on the local machine.
This shows how Popper helps improve the performance of scientific workflows drastically by allowing easy reproduction in cloud infrastructure.

### Workflow execution in Slurm clusters

For this case study, we modified our training script to use the Horovod [@horovod] distributed deep learning framework to facilitate training with MPI [@gropp1999using] in a Slurm cluster.
For running workflows in Slurm clusters, MPI supported container engines like Singularity, which is supported by popper need to be used.
The MPI based workflows can be made compatible between Slurm clusters with different MPI implementations, if the Singularity images used in the workflows are built on the cluster by binding to the local MPI libraries.
Also, the programs and scripts need to be MPI compatible to utilize the total compute capacity of multiple nodes in HPC clusters.
We recommend using a shared filesystem like NFS or AFS [@howard1988overview] mounted on each node and placing the workflow context in there to keep the workspace consistent across all the nodes.
We used 3 VMs from Azure each with the same NVIDIA 12GB PCI P100 GPU running Ubuntu 18.04 for this experiment and used Singularity as the container engine for running this workflow.
We used `mpich` which is a popular implementation of MPI, with Singularity following the bind approach, where we install MPI on the host and then bind mount the `/path/to/mpi/bin` and `/path/to/mpi/lib` of the MPI package inside the Singularity container for the MPI version in the host and the container to stay consistent.
The training step was run using MPI on 2 compute nodes having a GPU each and the training parameters were the same as in the previous case studies.

As we can see from @Fig:casestudies, Popper allowed us to run the workflow in a Slurm cluster with MPI and hence utilize the processing power of multiple GPUs and drastically reduce the training duration.

### Workflow execution on CI

We pushed our MNIST project to GitHub and activated the repository in Travis to run our workflows on CI.
For long-running workflows like those consisting of ML/AI or BigData workloads, it is recommended to scale down various parameters like dataset size, epochs, etc. with the help of environment variables to reduce the CI running time and iterate quickly. 
We declared environment variables like `NUM_EPOCHS`, `DATASET_REDUCTION`, and `BATCH_SIZE` to control the number of epochs, size of training data, and batch size respectively in our workflow.
Using the above variables we used only 10% of the dataset and configured the training for a single epoch, thus effectively reducing our CI running time by approx. 75%.
The `.travis.yml` file used by our case study is shown in @Lst:travis.
It can be generated by running `popper ci travis` from the command line.

```{#lst:travis .yaml caption="Popper generated Travis config."}
---
dist: xenial
language: python
python: 3.7
services: docker
install:
- git clone https://github.com/systemslab/popper /tmp/popper
- export PYTHONUNBUFFERED=1
- pip install /tmp/popper/src
script: popper run -f wf.yml
```

By setting up CI for Popper workflows, users can continuously validate changes made to their workflows and also protect their workflows from getting outdated due to reasons such as outdated dependencies, outdated container images, broken links, etc.

# Discussion {#sec:result}

A summary of the training duration and accuracy obtained by running the workflow in three different computing environment is shown in @Fig:casestudies.
As one would expect, running the same workflow on better, larger hardware resources reduces the amount of time needed to train the models.

This case study showcases the benefits of using Popper: having portable workflows drastically reduces software development and debugging time by enabling developers and researchers to quickly iterate and test the same workflow logic in different computing environments.
To expand on this point, we analyzed the GitHub repository [^mlperf] of MLPerf [@mattson2019mlperf], a benchmark suite that measures how fast a system can train ML models.
From a total of 123 issues, 67 were related to problems of reproducibility: missing or outdated versions of dependencies, documentation not aligning with the code, missing or broken links for datasets; etc.
Popper can solve much of the problems generally noticed in reproducing research artifacts like these we found.

As exemplified in the use cases, Popper helps build workflows that can be run on Cloud and HPC environments besides the local machine with minimal changes in configuration in a sustainable fashion.
The adjustments that users need to make to reproduce workflows on Kubernetes and Slurm is described below.

1. To run workflows on Kubernetes clusters, users need to pass some configuration options through a YAML file with contents similar to the one shown in @Lst:kubernetes. 
The `volume_size` and `namespace` options are not required if the defaults are suitable for running the workflow but we show it here to depict some ways in which the Kubernetes resource manager can be customized.

```{#lst:kubernetes .yaml caption="Config file for running on Kubernetes."}
resource_manager:
  name: kubernetes
  options:
    volume_size: 4Gi
    namespace: mynamespace
```

2. Similarly, for running on Slurm, users need to specify a few configuration options like the number of nodes to use for running the job concurrently, the number of CPUs to allocate to each task, the worker nodes to use, etc. as shown in @Lst:slurm.

```{#lst:slurm .yaml caption="Config file for running on Slurm."}
engine:
  name: singularity

resource_manager:
  name: slurm
  options:
    run-training:
      nodes: 2
      nodelist: worker1,worker2
      cpus-per-task: 2
```

It can be seen that with few tweaks like changing the resource manager options in the configuration file, a workflow developed on a local machine can be executed in Kubernetes and Slurm.
In this way, Popper allows researchers and developers to build and test workflows in different computing environments with relatively minimal effort.

[^mlperf]: <https://github.com/mlperf/training>

# Related Work

The problem of implementing multi-container workflows as described in @Sec:intro is addressed by several existing tools.
We briefly survey some of these tools and technologies and compare them with Popper by grouping them in categories.

## Workflow definition languages

Standard workflow definition languages like CWL [@amstutz2016common], WDL [@_openwdl_], and YAWL [@van2005yawl] provide an engine agnostic interface for specifying workflows declaratively. 
Being engine agnostic, different workflow engines can adopt these languages as these workflow languages provide a plethora of useful syntactic elements to support a wide range of workflow engine features.
Some of these workflow definition languages provide syntax for fine-grained control of resources by the users like defining the amount of CPU and memory to be allocated to each step, specifying scheduling policies, etc.
Most of these languages support syntax for integration with various computing backends like container engines (e.g. Docker, uDocker [@gomes2018enabling], Singularity), HPC clusters (e.g. HTCondor [@tannenbaum2001condor], LSF [@wei2005implementing], Slurm), cloud providers (e.g. AWS, GCP, Azure), Kubernetes, etc.
For a user whose primary goal is to automate running a set of containerized scripts in sequence, learning these new workflow languages and syntaxes might add to the overall complexity.
One of Popper's primary goals is to minimize the workflow language overhead as much as possible by allowing users to specify workflows using vanilla YAML syntax, thus keeping the learning curve flat and preventing sources of confusion.

## Workflow execution engines

Workflow execution engines can be categorized in several different categories.
In this section, we have discussed three frequently used categories of workflow execution engines namely Generic, Cloud Native, and Container Native and compared their pros and cons with Popper.

### Generic workflow execution engines

Few examples of this category are stable and mature scientific workflow engines like Nextflow, Pegasus, and Taverna which have recently introduced support running steps in software containers;
Popular workflow engines like Airflow and Luigi [@_luigi_] require specifying workflows using programming languages and also provide pluggable interfaces that require the installation of separate plugins.
For example, Airflow and Luigi use Python, Copper [@_copper_engine_] uses Java, Dagr [@_dagr_] uses Scala and SciPipe [@lampa2019scipipe] uses Go as their workflow definition language.
The goal with Popper is to minimize overhead both in terms of workflow language syntax and infrastructural requirements for running workflows and hence allow users to focus solely on writing the workflows.
The first issue is already addressed in the previous subsection, but it's also relevant here because not all engines support standard workflow languages such as CWL, and also learning specific programming languages for workflow execution seems like an exaggeration.
Most of these popular workflow engines like Pegasus, Airflow, and Luigi also require a standalone service that users need to learn how to deploy and interact with before executing workflows, thus adding to the complexity.
Popper also mitigates this issue as it can be downloaded and run as a standalone executable and does not assume any service deployment or infrastructural management before running workflows.

### Container native workflow execution engines

Container native paradigm encourages shifting the entire software development lifecycle which includes building, testing, debugging, and deployment to within software containers.
The workflow engines that assume running steps of a workflow inside separate containers are usually termed as container-native workflow engines.
Streamflow [@_streamflow_], Flyte [@_flyte_], and Dray [@_dray_] are some well-known examples of container-native workflow execution engines. 
Some of these container-native workflow engines like Flyte and Dray are built around a client-server architecture requiring some service deployment effort before being able to run workflows on them.
Popper falls in this category of container-native workflow engines but it does not assume any service deployment before running workflows, hence mitigating any extra service maintenance overhead or cost.

### Cloud-native workflow execution engines

Cloud-native computing is an emerging paradigm in software development that aims to utilize existing cloud infrastructure to build, run, and scale applications in the cloud.
The cloud-native paradigm is a subset of the container-native paradigm since it encourages running applications not only inside containers but also on cloud infrastructure.
Container engines like Docker and orchestration tools like Kubernetes have become an integral part of the cloud-native paradigm over the years.
With the wide-spread acceptance of the cloud-native paradigm, several cloud-native workflow engines like  Argo [@argocommunity_argoproj_2019], Pachyderm [@novella_containerbased_2018], Brigade [@brigade] have come into existence.
These workflow engines facilitate running workflows in the cloud by running an entire workflow in containers managed by Kubernetes.
The limitation of these workflow engines is the requirement of having access to a Kubernetes cluster which can block users from running workflows in the absence of one.
Although Popper can run workflows in the cloud using Kubernetes, it does not necessarily require access to a Kubernetes cluster for running the containerized steps of a workflow.
Popper is not exclusively cloud-native since it does not assume the presence of a Kubernetes cluster for running workflows, but in addition to being able to work as cloud-native i.e. run workflows on Kubernetes, it can also behave as container-native in different computing environments like a local machine, Slurm and cloud VM instances over SSH.

## Continuous Integration Tools

Continuous Integration is a DevOps practice that enables building and testing code frequently to prevent the accumulation of broken code and support faster development cycles.
Tools like Travis, Circle, Jenkins, and GitLab-CI have become the standard for doing CI, but they were primarily built for running on the Cloud.
This results in increased iteration time, especially for quick modify-compile-test loops, where the time spent in booting of VMs, scheduling of CI jobs becomes an overhead.
Reproducing experiments on the local machine that originally run on CI, requires manually setting up the entire development environment, making the entry barrier high.
Running on CI tools hosted locally, like using Gitlab-runner [@gitlabrunner], requires knowledge and expertise in deploying and using the specific tools.
Popper tackles these problems by providing a workflow abstraction that allows users to write a workflow once and run them interchangeably between different environments like a local machine, CI services, Cloud, and HPC by learning a single tool only.
Given the above, Popper is not intended to replace CI tools, but rather serve as an abstraction on top of CI services, helping to bridge the gap between a local and a CI environment.

## Related Case Studies

Popper aids in making experiments reproducible not only from ML/AI, but also from other areas of computer science like Networking, Storage systems, Computational genomics, etc.
Reproducibility issues in Systems experiments like experiments with File systems were also explored and tackled by Popper [@jimenez:ucsctr16]. 
Few network simulation experiments that run on the Cooja network simulation platform were made reproducible with the use of Popper [@david:precs19]. 
Additionally, tutorials on how Popper helps in producing reproducible research from different domains of computational science were held in various workshops and talks [@10.1145/3293883.3302575].

# Conclusion and Future Work {#sec:conclusionandfuturework}

In this paper, we present Popper, a container-native workflow execution engine that aims to solve the reproducibility problem in computational science.
We first describe and analyze the design of Popper's YAML based workflow syntax and the architecture of the Popper workflow engine.
We present a few case studies using an ML workflow to demonstrate how Popper helps developers and researchers build and test workflows in different computing environments like a local machine, Kubernetes, and Slurm quickly and with minimal changes in configuration.
Next, we compare Popper with existing state-of-the-art workflow engines illustrating its YAML based workflow syntax that has a relatively low entry barrier and its ability to run containerized workflows without requiring access to any cloud environment.

As future work, we have planned to add support for more container engines like NVIDIA Pyxis, Charliecloud, Shifter and resource managers like HTCondor, TORQUE to Popper in order to extend the range of the different computing environments currently supported.
We also plan to add a compatibility layer between the Popper syntax and more advanced workflow languages such as CWL/WDL to enable interoperability between different workflow engines.
This would also allow Popper users to migrate to other workflow engines without making any changes to their previously written workflows, thus keeping the overhead minimal.
Several other features have also been planned like workflow report generation, GUI dashboard, etc. to make the tool more user friendly.

# References {#sec:references}
\footnotesize
