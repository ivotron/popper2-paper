---
title: "Popper 2.0: A Container-Native Workflow Execution Engine For Testing Complex Applications and Reproducing Scientific Explorations"
author: Ivo Jimenez, Jayjeet Chakraborty, Arshul Mansoori, Quincy Wofford and Carlos Maltzahn
abstract: |
   The problem of reproducibility and replication in scientific research is quite prevalent to date. 
   Researchers working in fields of computational science often find it difficult to reproduce experiments from artifacts like code, data, diagrams and results which are left behind by the previous researchers. 
   The code developed on one machine often fails to run on other machines due to differences in hardware architecture, OS, software dependencies, among others. 
   This is accompanied by the difficulty in understanding how artifacts are organized, as well as in using them in correct order. 
   Since this problem of platform dependency can be solved by using software containers, i.e. light-weight virtualization, researchers and developers have built scientific workflow engines that organize the steps of a workflow as the nodes of a directed acyclic graph (DAG) and run them in separate containers.
   But these existing container-native workflow engines assume the availability of a Kubernetes cluster deployed in the cloud, access to which is not always trivial.
   Therefore, there is a need for a container-native workflow engine that does not assume the presence of a Kubernetes cluster or any other specific computing environment.
   In this paper, we introduce Popper, a container-native workflow engine that executes each step of a workflow in a separate dedicated container without assuming the presence of a Kubernetes cluster or any cloud based Kubernetes service.
   We also discuss the design and architecture of Popper and how it abstracts away the complexity of multiple container engines and resource managers, enabling users to focus only on writing workflows.
   With Popper, researchers can build and validate workflows easily in almost any environment of their choice including local machines, Slurm based HPC clusters, CI services or Kubernetes based cloud computing environments. 
   To exemplify the suitability of this workflow engine, we present three case studies where we take examples from Machine Learning and High Performance Computing and turn them into Popper workflows.
---

# Introduction {#sec:intro}

<!-- defining the problem of reproducibility in computational science -->

Around 48.6% of scientists and researchers working in various domains related to computational science, upload experimental artifacts like code, figures, datasets, configuration files, etc. on open-access repositories like Zenodo [@_zenodo_], Figshare [@_figshare_] or GitHub [@github]. 
Unfortunately, only 1.1% of the artifacts available online are fully reproducible and 0.6% of them are partially reproducible [@stagge2019assessing]. 
According to a study of 2016 by Nature, among a group of 1576 scientists around 70% of them failed to reproduce each other's experiments [@baker2016reproducibility].
This problem occurs mostly due to the lack of proper documentation, missing artifacts, broken software dependencies, etc. 
This results in other researchers wasting time trying to figure out how to reproduce those experiments from the archived artifacts, ultimately making this process inefficient, cumbersome and error prone [@sep-scientific-reproducibility].

![An end-to-end example of a workflow. On the left, we have the `.yml` file that defines the workflow. On the right, a pictorial representation of it.](./figures/casestudy.png){#fig:casestudy}

<!-- discuss previous work -->

Numerous existing research have tried to address the problem of reproducibility [@goodman2016does] in distinct ways like logging and tracing systemcalls, using workflow engines, using correctly provisioned shared and public testbeds, by recording and replaying changes from a stable initial state, etc [@reproducibility2018acm] and these led to the development of various tools and frameworks [@piccolo2016tools] [@peng2011reproducible].
Scientific workflow engines have been a predominant solution [@stevens2013automated] [@banati2015minimal] [@qasha2016framework] for handling the reproducibility problem by organizing the steps in a complex scientific workflow as the nodes of a directed acyclic graph (DAG) and executing them in correct order [@albrecht2012makeflow].
Nextflow [@ditommaso_nextflow_2017], Pegasus [@deelman_pegasus_2004] and Taverna [@oinn_taverna_2004] are examples of widely used scientific workflow engines.
But some phenomena like unavailability of third-party services, missing example input data, changes in the execution environment, insufficient documentation of workflows make it difficult for scientists to reuse workflows, thus causing what is known as _workflow decay_ [@workflow_decay].

<!-- attempts to solves using containers and what problem still remains -->

One of the main reasons behind _workflow decay_ is the differences in the environment where the workflows are developed and where they are reproduced [@meng2017facilitating]. 
VM's were used to address this problem for some time due to their high isolation gurantees, where every step of a workflow ran inside a separate VM [@howe2012virtual] [@virtandnestedvirt2012].
Since VM's had large resource footprints, researchers replaced VM's with software containers, i.e. light-weight virtualization technologies to provide platform-independent reproducibility [@barik2016performance] [@sharma2016containers].
Although software (Linux) containers are a relatively old technology [@menage_adding_2007], it was not until recently, with the rise of Docker, that they entered mainstream territory [@bernstein_containers_2014]. 
Since then, this technology has transformed the way applications get deployed in shared infrastructures, with 25% of companies using this form of software deployment [@datadog_surprising_2018], and a market size projected to be close to 5B by 2023 [@marketsandmarkets_application_2018]. 
Docker has been the de facto container runtime, with other container runtimes such as Singularity [@kurtzer_singularity_2017], Rkt [@rktcommunity_rkt_2019], Charliecloud [@priedhorsky_charliecloud_2017] and Podman [@podmancommunity_containers_2019] having emerged. 
The Linux Foundation bootstrapped the Open Container Initiative (OCI) [@opencontainerinitiative_new_2016] and is close to releasing version 1.0 of a container image and runtime specifications. 
With Docker, the container-native software development paradigm emerged, which promotes the building, testing, and deployment of software in containers, so that users do not need to install and maintain packages on their machines, rather they can build or fetch container images which have all the dependencies present. 
Since, these container runtimes are available for almost every well known operating system and architecture, experiments can be reproduced easily using containerized workflows in almost any environment [@stubbs2016endofday] [@zheng_integrating_2015].
Although, there are different container engines available, switching between them is difficult as they have different API's, image formats, CLI interfaces, among many other.
In addition there is an absence of tools that allow running containerized workflows in an engine agnostic way.
It has also been found that as scientific workflows become increasingly complex, continuous validation of the workflows which is critical to ensuring good reproducibility, becomes difficult [@deelman2018future] [@cohen2017scientific].
Currently, different container-based workflow engines are available but all of them assume the presence of a fully provisioned Kubernetes [@kubernetes_google] cluster.
The practice of running applications and workflows in Kubernetes is commonly referred to as cloud-native [@balalaie2016microservices]. 
The difference between cloud-native and container-native is that, in the former, a Kubernetes cluster is required, while in the latter, only a container engine is required.
Argo [@argocommunity_argoproj_2019], Pachyderm [@novella_containerbased_2018] and Brigade [@brigade] are popular examples of cloud-native workflow execution engines.
The presence of a Kubernetes cluster or a cloud computing environment should not be a hardcore requirement for reproducing any experiment in a container-native manner, since it is often costly [@rodriguez2020container] to get access to one and this in turn makes reproducibility complex. 
It would be more convenient for researchers if workflow engines provide the flexibility of running workflows in a wide range of computing environments including those of their choice. 

<!-- our contributions -->

Popper [@systemslabpopper] is a light-weight workflow execution engine that allows users to follow the container-native paradigm for building reproducible workflows from archived experimental artifacts. 
This paper makes the following contributions:

1. The design and architecture of a container-native workflow engine that abstracts multiple resource managers and container engines giving users the ability to focus only on Dockerfiles, i.e. software dependencies and workflow logic, i.e. correct order of execution, and ignore the runtime specific details.
   This arrangement also provides built-in support for continuous validation and portability of workflows which empowers researchers to develop workflows once and run interchangeably between CI services like Travis, Jenkins, etc. and the local machine without any modifications. 

2. Popper, an implementation of the above design that allows running workflows inside containers in different computing environments like local machines, Kubernetes clusters or HPC [@yang2005high] environments.

3. Three case studies on how Popper can be used to quickly reproduce complex workflows in different computing environments. 
   We show how an entire Machine Learning workflow can be run on a local machine during development and how it can be reproduced in a Kubernetes cluster with GPU's to scale up and collect results. 
   We also show how a HPC workflow developed on the local machine can be reproduced easily in a Slurm [@slurm] cluster.

# Popper 2.0 {#sec:popper}

## Background

In this section, we provide a background on the different tools and technologies that are crucial to Popper for building container-native and reproducible workflows.

### **Docker**

Docker is an industry standard daemon based light-weight virtualization technology that was released in early 2013.
It uses various Linux kernel features like namespaces and cgroups to segregate processes so that they can run independently.
It provides state of the art isolation gurantees and makes it easy to build, deploy and run applications using containers following the OCI (Open Container Initiative) [@oci] specifications. 
However, it was not designed for use in multi-user HPC environments and also has significant security issues [@yasrab2018mitigating], which might enable an user inside a Docker container to have root access to the host systems network, filesystem, processes, etc. thus making it unsuitable for use in HPC systems. 
Also, Docker uses cgroups [@rosen2013resource] to isolate containers, which conflicts with the Slurm scheduler since it also uses cgroups to allocate resources to jobs and enforce limits [@brayford2019deploying].

### **Singularity**

Singularity is a daemonless scientific container technology built by LBNL (Lawrence Berkley National Laboratory) and first released in 2016. 
It is designed to be simple, fast, secure and provides containerized solutions for HPC systems supporting several HPC components such as resource managers, job schedulers and contains native MPI [@mpi1993] features. 
One of the main goals of Singularity is to bring container technology and reproducibility to the High Performance Computing world. 
The key feature that differentiates it from Docker is that it can be used in non-privileged computing environments like the compute nodes of HPC clusters, without any modifications to the software. 
It also provides an abstraction that enables using container images from different image registries interchangeably like Docker Hub, Singularity Hub and Sylabs Cloud.
These features make Singularity increasingly useful in areas of Machine learning, Deep learning and other data intensive applications where the workloads benefit from the HPC support of it.

### **Slurm**

Slurm is an open-source cluster resource management and job scheduling system developed by LLNL (Lawrence Livemore National Laboratory) for Linux clusters ranging from a few nodes to thousands of nodes. 
It is simple, scalable, portable, fault-tolerant, secure and interconnect agnostic. 
It is used as a workload manager by almost 60% of the world's top 500 supercomputers [@ibrahim2017algorithms]. 
Slurm provides a plugin based mechanism for simplyfying its use across different compute infrastructures.
It enables both exclusive and non-exclusive allocation of resources like compute nodes to the users. 
It provides a framework for starting, executing, and monitoring parallel jobs on a set of allocated nodes and arbitrates conflicting requests for resources by managing a queue of pending work. 
Slurm runs as a daemon in the compute nodes and also provides an easy to use CLI interface.

### **Kubernetes**

Kubernetes is a production-grade open source container orchestration system written in Golang that automates many of the manual processes involved in deploying, scaling and managing of containerized applications across a cluster of hosts. 
A cluster can span hosts accross public, private or hybrid clouds. 
This makes Kubernetes an ideal platform for hosting cloud-native applications. 
Kubernetes supports a wide-range of container runtimes including Docker, Rkt and Podman. 
It was originally developed and designed by engineers at Google and it is hosted and maintained by the CNCF (Cloud Native Computing Foundation). 
Many cloud providers like GCP, AWS and Microsoft Azure provide a completely managed and secure hosted Kubernetes platform.

### **Continuous Integration**

Continuous Integration is a software development paradigm where developers commit code into a shared repository frequently, ideally several times a day.
Each integration is verified by automated builds and tests of the corresponding commits.
This helps in detecting errors and anomalies quickly and shortens the debugging time [@virmani2015understanding].
Several hosted CI services like Travis, Circle and Jenkins make continuous integration and continuous validation easily accessible.

## Workflow Definition Language

YAML [@ben2009yaml] is a human-readable data-serialization language. 
It is commonly used in writing configuration files and in applications where data is stored or transmitted. 
Due to its simplicity and wide adoption [@yaml_wide_adoption], we chose YAML for defining popper workflows and for specifying configuration for the execution engine. 
An example is shown in @Fig:casestudy.

A popper workflow consists of a series of syntactical components called steps, where each step represents a node in the workflow DAG, with a `uses` attribute specifying the required container image. 
The `uses` attribute can reference Docker images hosted in container image registries; filesystem paths for locally defined container images (Dockerfiles); or publicly accessible GitHub repositories that contain Dockerfiles. 
The commands or scripts that need to be executed in a container can be defined by the `args` and `runs` attributes. 
Secrets and environment variables needed by a step can be specified by the `secrets` and `env` attributes respectively for making them available inside the container associated to a step.
The steps in a workflow are executed sequentially in the order in which they are defined.

## Workflow Execution Engine

The Popper workflow execution engine is composed of several components which talk to each other during a workflow execution.
The vital architectural components of the system are described in detail throughout this section.

### **Command line interface (CLI)**

Besides allowing users to communicate with the workflow runner, the CLI provides with search capabilities so that users can search for existing actions implemented by other researchers and developers;
allows visualizing workflows by generating DOT diagrams [@dot] like the one shown in @Fig:casestudy;
generates configuration files for continuous integration systems, e.g. TravisCI, Jenkins, Gitlab-CI, etc. so that users can continuously validate the workflows they implement;
provides dynamic workflow variable substitution capabilities, among others.

### **Workflow Runner**

The Workflow runner is in charge of parsing the `.yml` files, i.e. the workflow files and the configuration files through their corresponding parsers and creating an internal representation for it. 
It also downloads actions referenced by the steps in the workflow, checks the presence of secrets that are used in a workflow and routes the execution of a step to the configured container engine through the requested resource manager. 
The runner also maintains a cache directory to optimize multiple aspects of execution such as avoid cloning repositories if they have already cloned previously. 
Thus, this component orchestrates the entire workflow execution process.

### **Parser**

The workflow file and the configuration file are parsed by their respective parser plugins at the initial stages of a workflow execution.
The parsers are responsible for reading and parsing the YML files into an internal format;
running syntactic and semantic validation checks;
normalizing the various attributes and generating a workflow DAG.
The parsed file contents are represented internally with the help of different Python data structures like `dict` and `list`.
Support of new workflow languages can be added by writing language specific plugins.

### **Resource manager and Container engine API**

Popper supports running containers in both single-node and multi-node cluster environments. 
Each of these different environments have very specific job and process scheduling policies. 
The resource manager API is a pluggable interface that allows the creation of plugins (also referred to as runners) for distinct job schedulers (e.g. SLURM, SGE, HTCondor, etc.) and cluster managers (e.g. Kubernetes, Mesos, YARN, etc.). 
Currently, plugins for Slurm and Kubernetes exist, as well as the default local runner that executes workflows on the local machine where Popper is executed.
Each resource manager plugin supports running containers from different container engine vendors through their corresponding plugins.
The container engine plugins expose generic operations that all engines support such as creating an image from a `Dockerfile`;
downloading images from a registry and converting them to their internal format;
and container-level operations such as creation, deletion, renaming, etc.
Currently, there are plugins for Docker and Singularity, with others planned by the Popper community.

In addition, the container engine abstraction layer supports the specialization of an engine by allowing users to provide engine specific configuration through the configuration file. 
The same can be achieved for resource managers as well.
This enables users to take advantage of engine and resource manager specific features in a transparent way.
For example, in the case of Singularity, this file can contain information about the MPI library available on a cluster.
The configuration file can be passed through the CLI interface and can be shared among different workflows.
It can either be created by users or provided by system administrators.

# Case Study {#sec:study}

### **Single-Node local workflow execution**

### **Workflow execution in the Cloud using Kubernetes**

### **Exascale workflow execution in SLURM clusters**

# Results {#sec:result}

## System Resource Usage

## Overheads

# Related Work

### **Workflow defination languages**

### **Generic workflow execution engines**

### **Container native workflow execution engines**

# Conclusion {#sec:conclusion}

## Benefits

## Challenges

## Learning Curve

# Future Work {#sec:futurework}

# References {#sec:references}
