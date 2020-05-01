---
title: "Popper 2.0: A Container-Native Workflow Execution Engine For Testing Complex Applications and Reproducing Scientific Explorations"
author: Ivo Jimenez, Jayjeet Chakraborty, Arshul Mansoori, Quincy Wofford and Carlos Maltzahn
abstract: |
    The problem of reproducibility and replication in scientific research is 
    quite prevalent to date. Researchers working in fields of computational 
    science often find it difficult to reproduce experiments from their artifacts 
    like code, data, diagrams, results, etc. left behind by the previous 
    researcher. According to a study of 2016 by Nature, among a group of 1576 
    scientists around 70% of them failed to reproduce each other's experiments. 
    The code developed on one machine often fail to run in other machines due to 
    differences in OS, architecture, etc. This is accompanied by the 
    difficulty of organizing and using the experimental artifacts in the correct 
    order. Researchers have tried to solve this problem successfully in the past by 
    building and using workflow engines. With the advent of light-weight virtualization technologies in the form of containers, researchers
    and developers have built various workflow engines like Argo, Pachyderm, Brigade, etc. for executing workflows inside containers through Kubernetes clusters. This poses an extra overhead of the availability of Kubernetes clusters deployed in the cloud even when such an arrangement is not always necessary. Also, there are workflow engines like Nextflow and Pegasus that do not enforce execution in containers and hence makes the workflows less portable. We introduce Popper, a container-native workflow engine that executes each step of a workflow in its separate dedicated container in a wide range of computing environments. It does not require the presence of a Kubernetes cluster or any cloud Kubernetes service like Google's Kubernetes Engine (GKE), Elastic Kubernetes Services (EKS) from AWS or Microsoft Azure's Kubernetes service.
    With Popper, researchers can build and validate workflows easily in almost 
    any environment of their choice like a local machine, a supercomputing cluster
    or a Kubernetes based cloud environment. To exemplify the suitability of this workflow engine, we present three different case studies where we take examples from Machine 
    Learning and HPC experiments and turn them into Popper workflows.
---

# Introduction {#sec:intro}

<!-- there's a problem of reproducibility in science -->

Around 48.6% of scientists and researchers working in various domains related to computational science, upload experimental artifacts like code, figures, datasets, configuration files, etc. on open-access repositories like Zenodo [@_zenodo_], Figshare [@_figshare_] or Github [@github], etc. Unfortunately, only 1.1% of the artifacts available online are fully reproducible and 0.6% of them are partially reproducible [@stagge2019assessing]. This problem occurs mostly due to the lack of proper documentation, missing artifacts, broken software dependencies, etc. Consequently, this results in other researchers wasting time trying to figure out how to reproduce those experiments from the archived artifacts. Hence, it makes the process inefficient and cumbersome. This problem is known as the Reproducibility crisis or Replication crisis in science [@sep-scientific-reproducibility].

![An end-to-end example of a workflow. On the left, we have the 
`.yml` file that defines the workflow. On the right, a pictorial 
representation of it.](./figures/casestudy.png){#fig:casestudy}

<!-- this is what people have tried with workflow engines -->

Researchers have been working to solve the reproducibility problem [@rosendaal2017reproducibility] for a long time in the past leading to 
the development of various tools and frameworks which try to solve 
the problem in distinct ways [@peng2011reproducible]. Scientific workflow 
engines have been a predominant solution [@stevens2013automated][@banati2015minimal][@qasha2016framework] for handling this problem by organizing the steps in a 
complex scientific workflow as the nodes of a directed acyclic graph (DAG) 
and executing them in correct order [@cohen2017scientific][@sciprocauto2009workflow][@albrecht2012makeflow]. Ideally, workflows should improve the reproducibility 
of scientific applications by making it easier to share and reuse between 
scientists. However, scientists often find it difficult to reuse workflows 
created by others due to unavailability of 3rd party services, missing example 
input data, changes in the execution environment, insufficient description of 
the workflows causing what is known as _workflow decay_ [@workflow_decay]. 

<!-- attempts using VM's -->

The above problem is mostly because of the differences in the environment where the workflows are developed and the environment where they are being reproduced [@meng2017facilitating]. Researchers first tried to solve this problem using the 
traditional Virtual machine model where they ran every task inside a separate VM [@gruning2018practical][@howe2012virtual] as VM's facilitate creation of highly isolated portable execution environments [@ali2011virtual]. They built virtual machine images from their execution environments and used them for setting up VM's in the cloud to set up 
replicated environments [@virtandnestedvirt2012].

<!-- this is why it was still hard using VM's -->

Although, the above approach solved the platform dependency problem quite well, spawning 
VM's to do granular steps of a workflow was extremely inefficient [@barik2016performance]. When several VM's run on the same host, performance may be hindered if the computer it’s running on lacks sufficient power. This makes running workflows on commodity hardware extremely unlikely and inefficient. Resource utilization is quite high in the case of VM's 
as compared to containers [@sharma2016containers] since every VM runs a separate operating system on top of the host's operating system which adds overhead in memory and storage footprint [@zhang2018comparative]. This makes using VM's less scalable. Thus, these problems lead researchers to the question "Can we do better ?".

<!-- attempts using container  -->

Although Software (Linux) containers are a relatively old technology [@menage_adding_2007], it was not until recently, with the rise of Docker, that they entered mainstream territory [@bernstein_containers_2014]. Since then, this technology has transformed the way applications get deployed in shared infrastructures, with 25% of companies using this form of software deployment [@datadog_surprising_2018], and a market size projected to be close to 5B by 2023 [@marketsandmarkets_application_2018]. Docker has been the de facto container runtime, with other container runtimes such as Singularity [@kurtzer_singularity_2017], Charliecloud [@priedhorsky_charliecloud_2017] and Podman [@podmancommunity_containers_2019] having emerged. The Linux Foundation bootstrapped the Open Container Initiative (OCI) [@opencontainerinitiative_new_2016] and is close to releasing version 1.0 of a container image and runtime specifications. With Docker, began the era of container-native software development, which is a paradigm that promotes the building, testing, and deployment of software in containers. Software containers are well-known for being lightweight and
they solve most of the problems caused by using VM's. So, researchers started replacing VM's with containers in workflow engines for providing platform-independent reproducibility [@repocompscience2016][@piccolo2016tools]. Since, these container runtimes are available for almost every well known operating systems and architectures, experiments can be reproduced easily using containerized workflows in almost any environment [@zheng_integrating_2015].

<!-- this is how people tried solving reproducibility with containers and what problem is remaining and what are the contributions -->

Currently, the different container-based workflow engines that are available can be classified mainly into two categories. The first category involves engines that are inherently container-native but assume the presence of a fully provisioned Kubernetes [@kubernetes_google] cluster at their disposal for workflow execution. Therefore, this category of workflow engines could also be termed as cloud-native [@balalaie2016microservices]. Some popular examples of this type of workflow engines are Argo [@argocommunity_argoproj_2019], Pachyderm [@novella_containerbased_2018] and Brigade [@brigade]. The other category of workflow engines do not enforce container-based execution by default but provides plugins and extensions to execute steps in containers. Nextflow [@ditommaso_nextflow_2017] and Pegasus [@deelman_pegasus_2004] are some popular examples of this category. The presence of a Kubernetes cluster or a cloud computing environment should not be a hardcore requirement for reproducing any experiment in a 
container-native since it is often costly [@rodriguez2020container] to get access to one and inturn makes reproducibility complex. Hence, it should provide flexibility for their users to run workflows in a wide range of computing environments like a single-node local machine, an HPC environment [@yang2005high], a Kubernetes cluster or any cloud computing environment of their choice. Hence, the contributions of this paper are as follows:

1. A workflow engine called Popper, which follows a container-native strategy for building reproducible workflows from archived experimental artifacts. The core idea behind this tool is that it breaks a complex workflow into discrete steps and each step
executes inside a separate container. These containers can run on a wide variety of computing environments like the local machine, the cloud, or an HPC environment [@containerbasedvirt2013]. We provide a detailed description of the internals of the tool in section II. 

2. Three case studies of how Popper can be used to quickly reproduce complex workflows in different computing environments have been discussed in section III. We show how an entire Machine Learning workflow can be run on a local machine during development and how it can be reproduced in a Kubernetes cluster with GPU's to scale up and collect results. We also show how an HPC workflow developed on the local machine can be reproduced easily in a SLURM cluster [@slurm].

3. A detailed comparison of Popper with existing workflow engines is given in section V.

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
