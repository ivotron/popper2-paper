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

Scientists and researchers often leave experimental artifacts
like scripts, datasets, configuration files, etc after completing with
their work. These when accompanied by lack of proper documentation makes 
the reproduction of the experiment tedious. Even with proper documentation of the 
steps that one need to follow to reproduce the experiments and rebuild the outcomes, it becomes cumbersome due to the differences in the environment in which the artifacts 
were developed and in which they are being reproduced.

For example, consider a researcher working in a Windows environment
leaves behind a bunch of Windows PowerShell [@payette2006windows] scripts. Now, if some other researcher with access to a Linux machine only wants to run those scripts in correct order in their environment, it would become time taking and difficult. They will probably 
end up spending a huge amount of time setting up VM's, finding the 
appropriate OS and interpreting the correct order of execution of the steps, 
hence making the process highly inefficent and time consuming, which 
it does not need to be.

![An end-to-end example of a workflow. On the left we have the 
`.yml` file that defines the workflow. On the right, a pictorial 
representation of it.](./figures/casestudy.png){#fig:casestudy}

Through this paper, we aim to address the reproducibility problem [@goodman2016does] in research. We propose a methodology in which a complex experimental 
workflow is decomposed into several discrete steps and each step executes in a
separate container. Doing this way, makes the workflow platform independent. Although Software (Linux) containers [@javed2017linux] are a relatively old technology [@menage_adding_2007], it was not until recently, with the rise of Docker, that they entered mainstream territory [@bernstein_containers_2014]. Since then, this technology has transformed the way applications get deployed in shared infrastructures, with 25% of companies using this form of software deployment [@datadog_surprising_2018], and a market size projected to be close to 5B by 2023 [@marketsandmarkets_application_2018]. Docker has been the *de facto* container runtime, with other container runtimes such as Singularity [@kurtzer_singularity_2017], Charliecloud [@priedhorsky_charliecloud_2017] and Podman [@podmancommunity_containers_2019] having emerged. Since, these container runtimes are available for almost every well known operating systems and architectures, experiments can be reproduced easily using containerized workflows in almost any environment.

At this point, one might think "*Why not use a single container for the entire workflow ?*". 
There are scenarios where a single container image is not suitable for implementing workflows associated to complex application testing or validating scientific explorations 
[@zheng_integrating_2015]. For example, a workflow might involve 
executing two steps, both of them requiring conflicting versions of a 
language runtime (e.g. Python 2.7 **and** Python 3.6). In this 
scenario, users could resort to solving such conflicts with the use of 
package managers [@package_managers_wiki], but this defeats the purpose of containers, which is to _not_ have to do this sort of thing inside a container. More 
generally, the more complex a container image definition gets (a more 
complex `Dockerfile`), the more "monolithic" it gets, and thus the 
less maintainable and reusable it is. On the other hand, if an 
experimentation workflow can be broken down into finer granular 
units, we end up having pieces of logic that are easier to maintain 
and reuse.

The above problem has been addressed by several tools in the past in distinct
ways. Some popular Kubernetes [@kubernetes_google] based workflow engines include Argo [@argocommunity_argoproj_2019] and 
Pachyderm [@novella_containerbased_2018] which requires access to a fully provisioned Kubernetes cluster. Some stable and generic workflow engines include Taverna [@oinn_taverna_2004] and Pegasus[@deelman_pegasus_2004] which use custom workflow defination languages and assume workflow engine deployment prior to executing workflows.

The main contribution of this paper is the tool called Popper, which follows a container-native [@container_native] strategy for building reproducible worflows from experimental artifacts. We provide a detailed description of the tool in section II. In section III, we present three case studies of how Popper can be used to quickly reproduce complex workflows in different computing environments. We also present a detailed comparison of Popper with existing workflow engines in section V.

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
