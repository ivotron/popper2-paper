---
title: "Popper 2.0: A Multi-container Workflow Execution Engine For Testing Complex Applications and Validating Scientific Explorations"
author: Ivo Jimenez, Jayjeet Chakraborty, Arshul Mansoori, Quincy Wofford and Carlos Maltzahn
abstract: |
 Software containers allow users to "bring their own environment" to 
 shared computing platforms, reducing the friction between system 
 administrators and their users. In recent years, multiple container 
 runtimes have arisen, each addressing distinct needs (e.g. 
 Singularity, Podman, rkt, among others), and an ongoing effort from 
 the Linux Foundation (Open Container Initiative) is standardizing the 
 specification of Linux container runtimes. While containers solve a 
 big part of the "dependency hell" problem, there are scenarios where 
 multi-container workflows are not fully addressed by existing 
 runtimes or workflow engines. Current alternatives require a full 
 scheduler (e.g. Kubernetes), a scientific workflow engine (e.g. 
 Pegasus), or are constrained in the type of logic that users can 
 express (e.g. Docker-compose). Ideally, users should be able to 
 express workflows with the same user-friendliness and portability of 
 `Dockerfile`s (write once, run anywhere). In this article, we 
 introduce "Popper 2.0" a multi-container workflow execution engine 
 that allows users to express complex workflows similarly to how they 
 do it in other scientific workflow languages, but with the advantage 
 of running in container runtimes, bringing portability and ease of 
 use to HPC scenarios. Popper 2.0 cleanly separates the three main 
 concerns that are common in HPC scenarios: experimentation logic, 
 environment preparation, and system configuration. To exemplify the 
 suitability of the tool, we present a case study where we take the 
 experimentation pipeline defined for the SC19 Reproducibility 
 Challenge and turn it into a Popper workflow.
---

# Introduction {#sec:intro}

Although Software (Linux) containers are a relatively old technology 
[@menage_adding_2007], it was not until recently, with the rise of 
Docker, that they entered mainstream territory 
[@bernstein_containers_2014]. Since then, this technology has 
transformed the way applications get deployed in shared 
infrastructures, with 25% of companies using this form of 
software deployment [@datadog_surprising_2018], and a market size 
projected to be close to 5B by 2023 
[@marketsandmarkets_application_2018]. Docker has been the _de facto_ 
container runtime, with other container runtimes such as Singularity 
[@kurtzer_singularity_2017], Charliecloud 
[@priedhorsky_charliecloud_2017] and Podman[^podman] having emerged. 
The Linux Foundation bootstrapped the Open Container Initiative (OCI) 
[@opencontainerinitiative_new_2016] and is close to releasing version 
1.0 of a container image and runtime specifications.

[^podman]: <https://github.com/containers/libpod>

While containers solve a big part of the "dependency hell" problem 
[@merkel_docker_2014], there are scenarios where a single container 
image is not suitable for implementing workflows associated to complex 
application testing or validating scientific explorations 
[@zheng_integrating_2015]. For example, a workflow might involve 
executing two stages, both of them requiring conflicting versions of a 
language runtime (e.g. Python 2.7 **and** Python 3.6). In this 
scenario, users could resort to solving such conflicts with the use of 
package managers, but this defeats the purpose of containers, which is 
to _not_ have to do this sort of thing inside a container. More 
generally, the more complex a container image definition gets (a more 
complex `Dockerfile`), the more "monolithic" it gets, and thus the 
less maintainable and reusable it is. On the other hand, if an 
experimentation pipeline can be broken down into finer granularity 
units, we end up having pieces of logic that are easier to maintain 
and reuse.

![An end-to-end example of a workflow. On the left we have the 
`.workflow` file that defines the workflow. On the right, a pictorial 
representation of it.
](./figures/casestudy.pdf){#fig:casestudy}

Thus, we would like to break workflows into subunits, ideally having 
one container image per node in the directed acyclic graph (DAG) 
associated to the workflow. From the point of view of UX design, this 
opens the possibility for devising languages to express 
multi-container workflows such as the ones implemented in application 
testing and scientific study validations.

<!-- Singularity is targeted at HPC use cases [@singularity]. -->

# Popper 2.0

## Architecture

Here we describe the architecute or the dfd of popper

## YAML as the workflow defination language

Here we show how yml serves better than other config languages

## Workflow execution engine

Here we describe components of the workflow execution engine

### **Command line interface (PopperCLI)**

Here we talk about the features that PopperCLI provides.

### **Workflow runner**

Here we talk about the work of the Workflow Runner

### **Internal representation of the workflow**

Here we talk about how is the workflow interpreted internally

### **Resource managers**

Here we talk about the functions of the resource manager

### **Container runtimes**

Here we talk about the container runtimes.

### **Continuous evaluation** 

we talk about continuous evaluation of workflows

# Case Study {#sec:study}

## Background

### Docker

Here we talk about docker

### Singularity

here we talk about singularity

### SLURM

Here we talk about slurm

### Kubernetes

Here we talk about Kubernetes

### CI Services

Here we talk about some CI services

## Execution Scenarios

Here we describe the 3 different execution scenarios

### **Single-Node local workflow execution**

Single node workflow execution in the local machine
for development purposes

### **Workflow execution in the Cloud using Kubernetes**

Escalating the workflow execution to a GPU enabled cluster in
the cloud for production grade execution

### **Exascale workflow execution in SLURM clusters**

Planetscale workflow execution is super computing environments

# Results {#sec:result}

## Complexity

## System Resource Usage

## Overheads

# Conclusion {#sec:conclusion}

## Benefits

## Challenges

## Learning Curve

## Related Work

Here we talk about other workflow execution solutions 
and how popper differentiates to them.

### **Generic workflow execution engines**

### **Container native workflow execution engines**

### **Cloud native workflow execution engines**

### **Workflow defination languages**

# Future Work {#sec:futurework}

# References {#sec:references}
