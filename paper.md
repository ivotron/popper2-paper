---
title: "Popper 2.0: A Container-Native Workflow Execution Engine For Testing Complex Applications and Reproducing Scientific Explorations"
author: Ivo Jimenez, Jayjeet Chakraborty, Arshul Mansoori, Quincy Wofford and Carlos Maltzahn
abstract: |
    Reproducibility and Replication crisis is still a prevalent problem
    in scientific research. Researchers exploring the work done
    in a field often find it difficult to reproduce the experiments from the
    artifacts, i-e the code, data, diagrams, results left behind by the previous 
    researcher. People have tried to solve this problem in the past 
    and also has been successfull in different ways, mostly
    by building and using workflow execution engines. With the advent of 
    light-wight virtualization technologies in the form of containers, people 
    have tried packaging steps in a workflow inside containers and execute them in 
    cloud environments. Although this approach seems to work well, it poses an extra 
    overhead of availibility of Kubernetes clusters deployed in the cloud even
    when such an arrangement is not necessary. Therefore, as a potential solution
    to this problem we introduce Popper, a container-native workflow execution engine
    that executes each step in a workflow in a separate dedicated container in a 
    wide choice of computing environments. It does not require the presence of 
    any Kubernetes cluster or any such cloud based container orchestrator.
    With Popper, researchers can build and validate workflows easily in almost 
    any environment of their choice like a local machine, a supercomputing cluster
    or any orchestrated cloud environment. To exemplify the suitability of the tool, 
    we present three different case studies where we take examples from Machine 
    Learning and HPC experiments and turn them into Popper workflows.
---

# Introduction {#sec:intro}

<!-- the reproducibility problem -->

Scientists and researchers often leave experimental artifacts
like code, datasets, configuration files, etc. on open-access repositories like 
Zenodo [@_zenodo_] and Figshare [@_figshare_] after completing with
their research. These when accompanied by lack of proper documentation makes 
the reproduction of the experiment tedious [@sep-scientific-reproducibility]. Even with proper documentation of the steps that one need to follow to reproduce the experiments and rebuild the outcomes, it becomes cumbersome due to the differences in the environment [@merkel_docker_2014] in which the artifacts were developed and in which they are being reproduced.

For example, consider a researcher working in a Windows environment
leaves behind a bunch of Windows PowerShell scripts. Now, if some other researcher with access to a Linux machine only wants to run those scripts in correct order in their environment, it would become time taking and difficult. They will probably 
end up spending a huge amount of time setting up VM's, finding the 
appropriate OS and interpreting the correct order of execution of the steps, 
hence making the process highly inefficent and time consuming, which 
it does not need to be.

<!-- case study figure -->

![An end-to-end example of a workflow. On the left we have the 
`.yml` file that defines the workflow. On the right, a pictorial 
representation of it.](./figures/casestudy.png){#fig:casestudy}

<!-- what people have already done -->

The reproducibilty problem has been addressed by several tools in the 
past in distinct ways. Workflow execution engines [@workflow_engines] has been a 
predominant way of handling this problem by organizing the steps in a workflow as
directed acyclic graph (DAG) and executing them in correct order. Currently, the different
workflow execution engines that are available can be classified into two categories. 
First category, involves engines that are inherently container-native [@container_native]
but they assume the presence of a fully provisioned Kubernetes [@kubernetes] cluster at their disposal for workflow execution. Therefore, this category of workflow engines could 
also be termed as cloud-native [@cloud_native]. Some popular examples of this type of workflow execution engines are Argo [@argocommunity_argoproj_2019], Pachyderm[@novella_containerbased_2018] and Brigade. The other category of workflow 
engines do not enforce container based execution by default but provides some 
plugins to execute steps in containers. Nextflow [@nextflow] and Pegasus [@deelman_pegasus_2004] are some popular examples of this category of workflow engines.

<!-- what it hasnt solved -->

After studying the different workflow execution engines available, we discovered
the absence of a possible third category, which should enforce execution of workflows inside 
containers, hence making it container-native but should not enforce the presence of a Kubernetes cluster or a cloud computing environment. The presence of a Kubernetes cluster or a cloud computing environment should not be a hard core requirement for reproducing any experiment since it is costly to get access to one and inturn makes reproducibilty complex. Hence, it should provide flexibility for their users to run workflows in a wide range of computing environments like a single node local machine, a HPC environment, a Kubernetes cluster or any cloud computing environment of their choice.

<!-- how containers can address part of the problem -->

Container-Native software development is an emerging paradigm which promotes building, testing and deploying applications inside containers. Although Software (Linux) containers [@javed2017linux] are a relatively old technology [@menage_adding_2007], it was not until recently, with the rise of Docker, that they entered mainstream territory [@bernstein_containers_2014]. Since then, this technology has transformed the way applications get deployed in shared infrastructures, with 25% of companies using this form of software deployment [@datadog_surprising_2018], and a market size projected to be close to 5B by 2023 [@marketsandmarkets_application_2018]. Docker has been the *de facto* container runtime, with other container runtimes such as Singularity [@kurtzer_singularity_2017], Charliecloud [@priedhorsky_charliecloud_2017] and Podman [@podmancommunity_containers_2019] having emerged. Since, these container runtimes are available for almost every well known operating systems and architectures, experiments can be reproduced easily using containerized workflows in almost any environment.

At this point, one might think "*Why not use a single container for the entire workflow ?*". 
There are scenarios where a single container image is not suitable for implementing workflows associated to complex application testing or validating scientific explorations 
[@zheng_integrating_2015]. For example, a workflow might involve 
executing two steps, both of them requiring conflicting versions of a 
language runtime (e.g. Python 2.7 **and** Python 3.6). In this 
scenario, users could resort to solving such conflicts with the use of 
package managers, but this defeats the purpose of containers, which is to _not_ have to do this sort of thing inside a container. More 
generally, the more complex a container image definition gets (a more 
complex `Dockerfile`), the more "monolithic" it gets, and thus the 
less maintainable and reusable it is. On the other hand, if an 
experimentation workflow can be broken down into finer granular 
units, we end up having pieces of logic that are easier to maintain 
and reuse.

<!-- our contributions -->

Through this paper, we introduce a tool called Popper, which follows a container-native strategy for building reproducible workflows from archived experimental artifacts. The core idea behind this tool is that it breaks a complex workflow into discrete steps and each step
executes inside a separate container. These container can run on a wide variety of computing environments like the local machine, the cloud or an HPC environment. We provide a detailed description of the internals of the tool in section II. In section III, we present some case studies of how Popper can be used to quickly reproduce complex workflows in different computing environments. We show how an entire Machine Learning workflow can be run on a local machine during development and how it can be reproduced in a Kubernetes cluster with GPU's to collect results. We also show how a HPC workflow developed on the local machine can be reproduced easily in a SLURM cluster. Then we talk about how Popper differs from existing workflow execution engines in section V. We conclude with discussing some benefits and challenges of using Popper for solving the reproducibilty problem.

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
