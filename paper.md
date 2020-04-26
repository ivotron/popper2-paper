---
title: "Popper 2.0: A Container-Native Workflow Execution Engine For Testing Complex Applications and Reproducing Scientific Explorations"
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
 introduce "Popper 2.0" a container-native workflow execution engine 
 that allows users to express complex workflows similarly to how they 
 do it in other scientific workflow languages, but with the advantage 
 of running in container runtimes, bringing portability and ease of 
 use to HPC scenarios. Popper 2.0 cleanly separates the three main 
 concerns that are common in HPC scenarios: experimentation logic, 
 environment preparation, and system configuration. To exemplify the 
 suitability of the tool, we present three different case studies 
 where we take examples from Machine Learning and HPC experiments
 and turn them into Popper workflows.
---

# Introduction {#sec:intro}

Although Software (Linux) containers are a relatively old technology 
[@menage_adding_2007], it was not until recently, with the rise of 
Docker, that they entered mainstream territory 
[@bernstein_containers_2014]. Since then, this technology has 
transformed the way applications get deployed in shared 
infrastructures, with 25% of companies using this form of 
software deployment [@datadog_surprising_2018] (popularly termed as "cloud-native software development"), and a market size 
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
executing two steps, both of them requiring conflicting versions of a 
language runtime (e.g. Python 2.7 **and** Python 3.6). In this 
scenario, users could resort to solving such conflicts with the use of 
package managers, but this defeats the purpose of containers, which is 
to _not_ have to do this sort of thing inside a container. More 
generally, the more complex a container image definition gets (a more 
complex `Dockerfile`), the more "monolithic" it gets, and thus the 
less maintainable and reusable it is. On the other hand, if an 
experimentation pipeline can be broken down into finer granular 
units, we end up having pieces of logic that are easier to maintain 
and reuse.

![An end-to-end example of a workflow. On the left we have the 
`.yml` file that defines the workflow. On the right, a pictorial 
representation of it.
](./figures/casestudy.png){#fig:casestudy}

Through this paper, we propose a protocol in which a
complex workflow is decomposed into several steps and each step executes in a
separate container. This protocol is implemented through the tool called Popper,
which follows a container-native strategy for building reproducible worflows easily. The tool is described in detail in section II.
In section III, we present three case studies of how popper can be used 
to quickly reproduce complex workflows in different environments.
From the point of view of UX design, this opens the possibility for devising 
languages to express multi-container workflows such as the one implemented 
in application testing and scientific study evaluations.

# Popper 2.0

<!-- The goal of the Popper project [@jimenez_popper_2017] is to aid users in the implementation of workflows following a DevOps approach. Last year, the Popper team released version 1.0 of the command line tool, which allows users to specify workflows in a lightweight YAML syntax. In Popper 1.0, the nodes in a workflow DAG represent arbitrary Bash shell commands, leaving the burden of ensuring that this commands are portable to users. Additionally, as the project team kept incorporating user feedback, the YAML-based workflow definition syntax kept evolving and, over time, started to look like a workflow specification language. Thus the team decided that it was time to embrace workflow languages properly. Around this time, Github released Github Actions [@github_github_2018] (referred from this point on as GHA), a workflow language and code execution platform. The GHA workflow language is a subset of the HashiCorp Configuration Language (HCL)^hcl, a popular configuration language used in the DevOps community [@brikman_terraform_2017]. The GHA workflow language is one of the simplest workflow formats publicly and openly available; simplicity in this context being defined in terms of the number of syntactic elements of the language. This characteristic, along with the fact that the language specification assumes a containerized environment, made the GHA workflow language a great option for implementing Popper version 2.0. -->

In the remaining of this section we briefly expand on choosing YAML as the worflow specification language, as well as the design and implementation of the workflow execution engine (Popper 2.0); in particular, we dive into the container engine and the resource manager API layer.

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

## System Resource Usage

## Overheads

# Related Work

Here we talk about other workflow execution solutions 
and how popper differentiates to them.

### **Generic workflow execution engines**

### **Container native workflow execution engines**

### **Cloud native workflow execution engines**

### **Workflow defination languages**

# Conclusion {#sec:conclusion}

## Benefits

## Challenges

## Learning Curve

# Future Work {#sec:futurework}

# References {#sec:references}
