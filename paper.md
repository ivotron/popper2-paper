---
title: "Popper 2.0: A Container-Native Workflow Execution Engine For Testing Complex Applications and Reproducing Scientific Explorations"
author: Ivo Jimenez, Jayjeet Chakraborty, Arshul Mansoori, Quincy Wofford and Carlos Maltzahn
abstract: |
    Reproducibility and Replication crisis is still a prevalent problem
    in scientific research. Researchers exploring the work done
    in a field often find it difficult reproducing the experiments from their
    artifacts, i-e the code, data, diagrams, results left behind by the previous 
    researcher. Code developed on one machine often fail to run in other
    machines due to differences in OS, architecture, etc. This is accompanied
    by the difficulty of organising and using the experimental artifacts in correct 
    order. People have tried to solve this problem in the past and has been successfull
    to an extent by building and using workflow execution engines. With the advent of 
    light-wight virtualization technologies in the form of containers, people 
    have built various workflow engines for executing workflows inside 
    containers through Kubernetes clusters. Some workflow execution engines do not
    enforce execution in containers hence making the process platform dependent.
    But it poses an extra overhead of availibility of Kubernetes clusters deployed 
    in the cloud even when such an arrangement is not always necessary. Therefore, as 
    a solution to these problem we introduce Popper, a strictly container-native workflow execution engine that executes each step of a workflow in its separate dedicated container in a wide range of computing environments. It does not require 
    the presence of a Kubernetes cluster or any such cloud based container orchestrator.
    With Popper, researchers can build and validate workflows easily in almost 
    any environment of their choice like a local machine, a supercomputing cluster
    or a Kubernetes based cloud environment. To exemplify the suitability of the tool, 
    we present three different case studies where we take examples from Machine 
    Learning and HPC experiments and turn them into Popper workflows.
---

# Introduction {#sec:intro}

<!-- there's a problem of reproducibility in science -->

Scientists and researchers often leave experimental artifacts
like code, datasets, configuration files, etc. on open-access repositories like 
Zenodo [@_zenodo_], Figshare [@_figshare_] or Github[@github] without proper
instructions to reproduce after completing with their research. Therefore,
it results in one wasting a lot of time trying to figure out how to
reproduce the experiment from the archived artifacts. Hence, making the process 
extremely inefficient and cumbersome. This problem in known as the Reproducibility 
crisis or Replication crisis in science [@sep-scientific-reproducibility].

![An end-to-end example of a workflow. On the left we have the 
`.yml` file that defines the workflow. On the right, a pictorial 
representation of it.](./figures/casestudy.png){#fig:casestudy}

<!-- this is what people have tried with workflow engines -->

The reproducibilty problem [@rosendaal2017reproducibility] has been attempted several times in the past which led to the development of various tools and frameworks which tried 
to solve the problem in distinct ways [@peng2011reproducible]. Scientific workflow execution engines has 
been a predominant solution for handling this problem by organizing the steps in a 
complex scientific workflow as the nodes of a directed acyclic graph (DAG) and 
executing them in correct order [@cohen2017scientific][@sciprocauto2009workflow][@albrecht2012makeflow].
Ideally, workflows should improve the reproducibility of scientific applications 
by making it easier to share and reuse between scientists. However, scientists 
often find it difficult to reuse others workflows, which is known as _workflow decay_. [@workflow_decay]
This is mostly because of the differences in the environment where the workflows are developed and the environment where they are being reproduced [@meng2017facilitating]. Some people have tried to solve this problem using the traditional Virtual machine model where they execute every task inside a separate VM [@gruning2018practical][@howe2012virtual]. People built virtual machine images from their development environment and used for setting up VM's in the Cloud. [@virtandnestedvirt2012]

<!-- this is why it is still hard using VM's -->

Although, the above approach solves the platform dependency problem very well, spawing 
VM's to do granular steps of a workflow is very inefficient [@barik2016performance]. When several VM's are running on the same host, performance may be hindered if the computer it’s running on lacks sufficient power. This makes running workflows on commodity hardware extremely unlikely and inefficient. Resource utilization is very high in case of VM's 
since every VM requires a copy of the operating system running on top of
the host's operating system. In fact, a VM runs in a non-priviledged mode
which does not have the capability to execute many privileged instructions. 
Therefore, a hypervisor is needed to translate a VM instruction into an instruction 
that can be executed by the host [@zhang2018comparative]. All these makes using VM's less scalable. Therefore all of these leads us to a question "Can we do better ?".

<!-- what is container tech -->

Although Software (Linux) containers are a relatively old technology [@menage_adding_2007], it was not until recently, with the rise of Docker, that they entered mainstream territory [@bernstein_containers_2014]. Since then, this technology has transformed the way applications get deployed in shared infrastructures, with 25% of companies using this form of software deployment [@datadog_surprising_2018], and a market size projected to be close to 5B by 2023 [@marketsandmarkets_application_2018]. Docker has been the de facto container runtime, with other container runtimes such as Singularity [@kurtzer_singularity_2017], Charliecloud [@priedhorsky_charliecloud_2017] and Podman [@podmancommunity_containers_2019] having emerged. The Linux Foundation bootstrapped the Open Container Initiative (OCI) [@opencontainerinitiative_new_2016] and is close to releasing version 1.0 of a container image and runtime specifications. With Docker, began the era of container-native software development, which is a paradigm that promotes the building, testing and deployment of softwares in containers. Software containers are well-known for being lightweight and
they solve most of the problems caused by using VM's. So, people started replacing VM's with containers in workflow engines for providing platform independent reproducibility [@repocompscience2016][@piccolo2016tools]. Since, these container runtimes are available for almost every well known operating systems and architectures, experiments can be reproduced easily using containerized workflows in almost any environment [@zheng_integrating_2015].

<!-- this is how people tried solving reproducibility with containers -->

Currently, the different container based workflow execution engines that are available can be classified mainly into two categories. First category involves engines that are inherently container-native but assume the presence of a fully provisioned Kubernetes [@kubernetes_google] cluster at their disposal for workflow execution. Therefore, this category of workflow engines could also be termed as cloud-native [@balalaie2016microservices]. Some popular examples of this type of workflow execution engines are Argo [@argocommunity_argoproj_2019], Pachyderm[@novella_containerbased_2018] and Brigade[@brigade]. The other category of workflow engines do not enforce container based execution by default but provides some plugins and extensions to execute steps in containers. Nextflow [@ditommaso_nextflow_2017] and Pegasus [@deelman_pegasus_2004] are some popular examples of this category.

<!-- this is what the above problems don't solve -->

After studying the different workflow execution engines available, we discovered
the absence of a possible third category, which should enforce the execution of workflows inside containers, hence making it container-native but should not enforce the presence of a Kubernetes cluster or a cloud computing environment. The presence of a Kubernetes cluster or a cloud computing environment should not be a hard core requirement for reproducing any experiment since it is often costly [@rodriguez2020container] to get access to one and inturn makes reproducibilty complex. Hence, it should provide flexibility for their users to run workflows in a wide range of computing environments like a single node local machine, a HPC environment [@yang2005high], a Kubernetes cluster or any cloud computing environment of their choice.

<!-- this is our contributions -->

Through this paper, we introduce a tool called Popper, which follows a container-native strategy for building reproducible workflows from archived experimental artifacts [@jimenez_popper_2017]. The core idea behind this tool is that it breaks a complex workflow into discrete steps and each step
executes inside a separate container. These containers can run on a wide variety of computing environments like the local machine, the cloud or an HPC environment [@containerbasedvirt2013]. We provide a detailed description of the internals of the tool in section II. In section III, we present some case studies of how Popper can be used to quickly reproduce complex workflows in different computing environments. We show how an entire Machine Learning workflow can be run on a local machine during development and how it can be reproduced in a Kubernetes cluster with GPU's to scale up and collect results. We also show how a HPC workflow developed on the local machine can be reproduced easily in a SLURM cluster [@slurm]. Then we talk about how Popper differs from existing workflow execution engines in section V. We conclude with discussing some benefits and challenges of using Popper for solving the reproducibilty problem.

# Motivation {#sec:motivation}

# Popper 2.0 {#sec:popper}

## Background

### **Docker**

### **Singularity**

### **Podman**

### **Slurm**

### **Kubernetes**

## Workflow Defination Language

## Workflow Execution Engine

### **Command line interface (CLI)**

### **Workflow Runner**

### **Resource manager API**

### **Container engine API and plugins**

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
