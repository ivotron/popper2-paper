---
title: "Popper 2.0: A Container-based Workflow Execution Engine For Complex Applications and Experimentation Pipelines"
author: Ivo Jimenez, Jayjeet Chakraborty, Arshul Mansoori and Carlos Maltzahn
abstract: |
 Software containers allow users to "bring their own environment" to 
 shared computing platforms, reducing the friction between system 
 administrators and their users. In recent years, multiple container 
 runtimes have arised, each addressing distinct needs (e.g. 
 Singularity, Podman, rkt, among others), and an ongoing effort from 
 the Linux Foundation (Open Container Innitiative) is standardizing 
 the specification of Linux container runtimes. While containers solve 
 a big part of the "dependency hell" problem, there are scenarios 
 where multi-container workflows associated to complex applications 
 and experimentation pipelines are not fully addressed by existing 
 runtimes or workflow engines. Current alternatives require a full 
 scheduler (e.g. Kubernetes), scientific workflow engine (e.g. 
 Pegasus), or are constrained in the type of logic that users can 
 express (e.g. Docker-compose). Ideally, users should be able to 
 express workflows with the same user-friendliness and portability of 
 `Dockerfile`s (write once, run anywhere). In this article, we 
 introduce "Popper 2.0", a portable, multi-container workflow 
 execution layer that allows users to express complex workflows 
 similarly to how they do it in other scientific workflow languages, 
 but with the advantage of running on container runtimes, bringing 
 portability and ease of use to HPC scenarios. Popper 2.0 cleanly 
 separates the three main concerns that are common in HPC scenarios: 
 logic, environment preparation, and system configuration. To 
 exemplify the suitability of the tool, we present a case study where 
 we take the experimentation pipeline defined for the SC19 
 Reproducibility Challenge and turn it into a Popper workflow.
---

# Introduction {#sec:intro}

Containers are making it easier to reproduce results.

Most (if not all) of these runtimes support `Dockerfile`s as a way to 
specify the environment dependencies for an application.

The more complex the container image definition (a more complex 
`Dockerfile`), the more "monolithic" it gets, making it easier to. 
Instead, we can break it down into a workflow, which makes it more 
modular and more maintainable.

# Popper 2.0

## Language

## Execution engine (container runtime abstraction)

## Container runtime plugins

custom container configuration

# Case Study {#sec:study}

SC19 Reproducibility Challenge

# Discussion {#sec:discuss}

Benefits:

  * Fits well the researcher workflow: shell/python/R scripts are 
    still used. Dockerfiles allow them to specify how their 
    environment looks like; workflow allows them to leverage what's 
    out there

  * Workflow engine hides complexities/custom-setup of a container 
    engine. The researcher sees Dockerfile/workflow files; admins 
    configure the runtime and provide a config file that they pass to 
    Popper (e.g. GPU, batch schedulers, etc.).

Challenges:

  * Mainly cultural.

# Related Work {#sec:related}

  * docker-compose
  * scientific workflow engines
  * kubernetes-based workflow engines: pachyderm, argo
  * container-based package managers: snap, flatpack and appimage

# Bibliography

<!-- hanged biblio -->

\noindent
\vspace{-2em}
\setlength{\parindent}{-0.26in}
\setlength{\leftskip}{0.2in}
\setlength{\parskip}{8pt}
