---
title: "Popper 2.0: A Multi-container Workflow Execution Engine For Testing Applications and Validating Scientific Explorations"
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
 where multi-container workflows are not fully addressed by existing 
 runtimes or workflow engines. Current alternatives require a full 
 scheduler (e.g. Kubernetes), scientific workflow engine (e.g. 
 Pegasus), or are constrained in the type of logic that users can 
 express (e.g. Docker-compose). Ideally, users should be able to 
 express workflows with the same user-friendliness and portability of 
 `Dockerfile`s (write once, run anywhere). In this article, we 
 introduce "Popper 2.0" a multi-container workflow execution engine 
 that allows users to express complex workflows similarly to how they 
 do it in other scientific workflow languages, but with the advantage 
 of running in container runtimes, bringing portability and ease of 
 use to HPC scenarios. Popper 2.0 cleanly separates the three main 
 concerns that are common in HPC scenarios: logic, environment 
 preparation, and system configuration. To exemplify the suitability 
 of the tool, we present a case study where we take the 
 experimentation pipeline defined for the SC19 Reproducibility 
 Challenge and turn it into a Popper workflow.
---

# Introduction {#sec:intro}

Although Software (Linux) containers are a relatively old technology 
[@google-since-2006], it was not until recently, with the rise of 
Docker [@docker], that they entered mainstream territory 
[@docker-take-over]. Since then, this technology has transformed the 
way applications get deployed in shared infrastructures, with as much 
as X% of the cloud market using this form of software deployment 
[@too-much-containers]. Docker has been the _de facto_ standard, until 
recently, when other container runtimes such as rkt (Rocket) [@rkt], 
Singularity [@singularity] and, more recently, Podman [@podman], 
emerged. The Linux Foundation [@linux-foundation], anticipating any 
possible community fragmentation and a "container runtime 
distribution" war [@no-war], bootstrapped the Open Container 
Initiative (OCI) [@oci] and is close to releasing version 1.0 of a 
container image and runtime specification [@oci1.0]. This spec serves 
as the common ground for all companies wanting to innovate in the 
container runtime space.

While containers solve a big part of the "dependency hell" problem 
[@solved], there are scenarios where a single container image is not 
suitable for implementing workflows associated to complex application 
testing or validating scientific explorations. For example, a workflow 
might include two stages, both of them requiring conflicting versions 
of a language runtime (e.g. Python 2.7 **and** Python 3.6). In this 
scenario, users could in theory resort to managing such conflicts with 
the use of package managers, but this defeats the purpose of 
containers, which is to _not_ have to do this osrt of thing inside a 
container. More generally, the more complex a container image 
definition gets (a more complex `Dockerfile`), the more "monolithic" 
it gets, and thus the less maintainable and reusable it is. On the 
other hand, if an experimentation pipeline can be broken down into 
finer granularity units, we end up having pieces of logic that are 
easier to maintain and reuse.

Thus, we would like to break workflows into subunits, having one 
container image per node in the associated workflow DAG. From the 
point of view of UX design, this opens the possibility for devising 
languages to express multi-container workflows such as the ones 
implemented in application testing and scientific study validation.

<!-- Singularity is targeted at HPC use cases [@singularity]. -->

# Popper 2.0

The goal of the Popper project [@jimenez_popper_2017] is to aid users 
in the implementation of experimentation pipelines that follow a 
DevOps approach. Last year, the Popper team released version 1.0 of 
the command line tool, which allows users to specify workflows in YAML 
syntax (see [@fig:foo]). In Popper 1.0, the nodes in a workflow DAG 
represent arbitrary Bash shell commands, which is fragile and passes 
all the burden of self-contained workflow creation to users.

Additionally, as the project team kept incorporating user feedback, 
the YAML-based pipeline definition syntax (shown above) kept evolving 
and, over time, started to look like a workflow specification format; 
we decided it was time to embrace workflows properly. Around this 
time, Github released Github Actions (referred from this point on as 
GHA), a workflow language and code execution platform. The GHA 
workflow syntax is a subset of the Hashicorp Configuration Language 
(HCL) [@hcl] a popular configuration language used in the DevOps 
community [@terraform]. The GHA language is one of the simplest 
workflow formats available; where simplicity is quantified as number 
of syntactic elements there (see example below). This makes it a 
viable option for implementing workflows in many distinct domains.

In the remaining of this section we briefly introduce the GHA workflow 
language, as well as design and implementation of Popper 2.0, the 
execution engine; and in particular we dive in the pluggable container 
runtime component.

## Language

Popper is a workflow execution engine based on [Github 
actions](https://github.com/features/actions) (GHA) that allows you to 
execute GHA workflows locally on your machine. Popper workflows are 
defined in [HCL](https://github.com/hashicorp/hcl) syntax and behave 
like GHA workflows. The main difference with respect to GHA workflows 
is that, through [several extensions to the GHA 
syntax](https://popper.rtfd.io/en/latest/sections/extensions.html), a 
Popper workflow can execute actions in other runtimes in addition to 
Docker.

## Actions

The open actions specification allows anyone to implement distinct 
functionality, providing a great extensible framework that can address 
multiple needs.

All existing container runtimes support the `Dockerfile`, the first 
ever

## Execution engine (container runtime abstraction)

The design

## Container runtime plugins

Custom container configuration.

# Case Study {#sec:study}

SC19 Reproducibility Challenge

# Discussion {#sec:discuss}

Benefits:

  * Fits well the researcher workflow: shell/python/R scripts are 
    still used. Dockerfiles allow them to specify how their 
    environment looks like; gha allows them to reuse as much as 
    possible.

  * Workflow engine hides complexities/custom-setup of a container 
    engine. The researcher sees Dockerfile/workflow files; admins 
    configure the runtime and provide a config file that they pass to 
    Popper (e.g. GPU, batch schedulers, etc.).

  * This can be the bridge between HPC and cloud containers. The 
    roadmap of Popper envisions executing seamlessly on kubernetes (by 
    handling all the logic of deploying a scheduler under the hood or 
    connecting the application to an existing kubernetes-hosted batch 
    scheduler).

Challenges:

  * Mainly cultural; this is a DevOps-like workflow.

# Related Work {#sec:related}

  * docker-compose
  * workflow languages: commonwl, nextflow
  * kubernetes-based workflow engines: pachyderm, argo
  * container-based package managers: snap, flatpack and appimage

# Conclusion and Future Work

# Bibliography

<!-- hanged biblio -->

\noindent
\vspace{-2em}
\setlength{\parindent}{-0.26in}
\setlength{\leftskip}{0.2in}
\setlength{\parskip}{8pt}
