---
title: "Popper 2.0: A Container-Native Workflow Execution Engine For Testing Complex Applications and Reproducing Scientific Explorations"
author: Ivo Jimenez, Jayjeet Chakraborty, Arshul Mansoori, Quincy Wofford and Carlos Maltzahn
abstract: |
    The problem of reproducibility and replication in scientific research is quite prevalent to date. 
    Researchers working in fields of computational science often find it difficult to reproduce experiments from artifacts like code, data, diagrams and results which are left behind by the previous researchers. 
    The code developed on one machine often fails to run on other machines due to differences in hardware architecture, OS, software dependencies, among others. 
    This is accompanied by the difficulty in understanding how artifacts are organized, as well as in using them in correct order. 
    Since this problem of platform dependency can be solved by using Software containers (light weight virtualization), researchers and developers have built scientific workflow engines like Argo, Pachyderm, Brigade, etc. for organizing the steps in a workflow as Directed Acyclic Graphs and running them in separate containers.
    But these existing container-native workflow engines assume the availability of a Kubernetes cluster deployed in the cloud, access to which is not always trivial.
    Therefore, there is a need for a container-native workflow engine that does not assume the presence of a Kubernetes cluster or any other specific computing environment.
    In this paper, we introduce Popper, a container-native workflow engine that executes each step of a workflow in a separate dedicated container and does not assume the presence of a Kubernetes cluster or any cloud based Kubernetes service.
    With Popper, researchers can build and validate workflows easily in almost any environment of their choice like a local machine, a Slurm based HPC cluster or a Kubernetes based cloud computing environment. 
    To exemplify the suitability of this workflow engine, we present three case studies where we take examples from Machine Learning and HPC and turn them into Popper workflows.
---

# Introduction {#sec:intro}

<!-- defining the problem of reproducibility in computational science -->

Around 48.6% of scientists and researchers working in various domains related to computational science, upload experimental artifacts like code, figures, datasets, configuration files, etc. on open-access repositories like Zenodo [@_zenodo_], Figshare [@_figshare_] or GitHub [@github]. 
Unfortunately, only 1.1% of the artifacts available online are fully reproducible and 0.6% of them are partially reproducible [@stagge2019assessing]. 
According to a study of 2016 by Nature, among a group of 1576 scientists around 70% of them failed to reproduce each other's experiments [@baker2016reproducibility].
This problem occurs mostly due to the lack of proper documentation, missing artifacts, broken software dependencies, etc. 
Consequently, this results in other researchers wasting time trying to figure out how to reproduce those experiments from the archived artifacts. 
Hence, it makes the process inefficient and cumbersome leading to what is known as the Reproducibility crisis or Replication crisis in science [@sep-scientific-reproducibility].

![An end-to-end example of a workflow. On the left, we have the `.yml` file that defines the workflow. On the right, a pictorial representation of it.](./figures/casestudy.png){#fig:casestudy}

<!-- discuss previous work -->

Numerous existing research have tried to address the problem of reproducibility [@goodman2016does] in distinct ways like logging and tracing systemcalls, using workflow engines, using correctly provisioned shared and public testbeds, by recording and replaying changes from a stable initial state, etc [@reproducibility2018acm] and these led to the development of various tools and frameworks [@piccolo2016tools] [@peng2011reproducible].
Scientific workflow engines have been a predominant solution [@stevens2013automated] [@banati2015minimal] [@qasha2016framework] for handling the reproducibility problem by organizing the steps in a complex scientific workflow as the nodes of a directed acyclic graph (DAG) and executing them in correct order [@cohen2017scientific] [@albrecht2012makeflow].
Nextflow [@ditommaso_nextflow_2017], Pegasus [@deelman_pegasus_2004] and Taverna [@oinn_taverna_2004] are some popular examples of scientific workflow engines.
But some phenomena like unavailability of third-party services, missing example input data, changes in the execution environment, insufficient documentation of workflows make it difficult for scientists to reuse workflows, thus causing what is known as _workflow decay_ [@workflow_decay].

<!-- attempts to solves using containers  -->

One of the main reasons behind _workflow decay_ is the differences in the environment where the workflows are developed and where they are reproduced [@meng2017facilitating]. 
VM's were used to address this problem for some time due to their high isolation gurantees, where every task ran inside a separate VM [@howe2012virtual] [@virtandnestedvirt2012]. 
Since VM's had large resource footprints, researchers replaced VM's with Software containers i.e. with light-weight virtualization technologies to provide platform-independent reproducibility [@barik2016performance] [@sharma2016containers].
Although Software (Linux) containers are a relatively old technology [@menage_adding_2007], it was not until recently, with the rise of Docker, that they entered mainstream territory [@bernstein_containers_2014]. 
Since then, this technology has transformed the way applications get deployed in shared infrastructures, with 25% of companies using this form of software deployment [@datadog_surprising_2018], and a market size projected to be close to 5B by 2023 [@marketsandmarkets_application_2018]. 
Docker has been the de facto container runtime, with other container runtimes such as Singularity [@kurtzer_singularity_2017], Rkt [@rktcommunity_rkt_2019], Charliecloud [@priedhorsky_charliecloud_2017] and Podman [@podmancommunity_containers_2019] having emerged. 
The Linux Foundation bootstrapped the Open Container Initiative (OCI) [@opencontainerinitiative_new_2016] and is close to releasing version 1.0 of a container image and runtime specifications. 
With Docker, began the era of container-native software development, which is a paradigm that promotes the building, testing, and deployment of software in containers. 
Since, these container runtimes are available for almost every well known operating systems and architectures, experiments can be reproduced easily using containerized workflows in almost any environment [@stubbs2016endofday] [@zheng_integrating_2015].

<!-- what problem is remaining and what are the contributions -->

Although, there are different container engines available, switching between them is hard as they have different API's and image formats and also due to the absence of tools that allow running containerized workflows in an engine agnostic way.
Currently, the different container based workflow engines that are available involves engines that are inherently container-native but assume the presence of a fully provisioned Kubernetes [@kubernetes_google] cluster at their disposal for workflow execution. 
Therefore, this category of workflow engines could also be termed as cloud-native [@balalaie2016microservices]. 
Some popular examples of this type of workflow engines are Argo [@argocommunity_argoproj_2019], Pachyderm [@novella_containerbased_2018] and Brigade [@brigade]. 
The presence of a Kubernetes cluster or a cloud computing environment should not be a hardcore requirement for reproducing any experiment in a container-native manner, since it is often costly [@rodriguez2020container] to get access to one and this inturn makes reproducibility complex. 
Workflow engines should provide flexibility for their users to run workflows in a wide range of computing environments like a single-node local machine, a HPC environment [@yang2005high], a Kubernetes cluster or any other computing environment of their choice. 

Popper [@systemslabpopper] is a light-weight workflow execution engine that follows a container-native strategy for building reproducible workflows from archived experimental artifacts. 
This paper makes the following contributions:

1. A workflow engine design that allows running workflows inside containers on different computing environemnts like a local machine, a cloud computing environment or a HPC environment.

2. The design and architecture of a container-native workflow engine that abstracts resource managers and container engines giving users the ability to focus only on Dockerfiles i.e. software dependencies and workflow logic i.e. correct order of execution, and ignore the runtime specific details.

3. Popper, an implementation of the above design and a detailed discussion on its internals.

4. Three case studies on how Popper can be used to quickly reproduce complex workflows in different computing environments. 
   We show how an entire Machine Learning workflow can be run on a local machine during development and how it can be reproduced in a Kubernetes cluster with GPU's to scale up and collect results. 
   We also show how an HPC workflow developed on the local machine can be reproduced easily in a Slurm [@slurm] cluster.

5. A detailed comparison of Popper with existing generic and container-native workflow execution engines alongwith a comparison of YAML with popular workflow defination languages like HCL and CommonWL.

# Motivation {#sec:motivation}

# Popper 2.0 {#sec:popper}

## Background

### **Docker**

### **Singularity**

### **Podman**

### **Slurm**

### **Kubernetes**

## Workflow Definition Language

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
