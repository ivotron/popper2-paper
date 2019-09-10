---
title: "Popper 2.0: A Multi-container Workflow Execution Engine For Testing Complex Applications and Validating Scientific Explorations"
author: Ivo Jimenez, Jayjeet Chakraborty, Arshul Mansoori, Quincy Woford and Carlos Maltzahn
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
and, over time, started to look like a workflow specification; thus 
the team decided it was time to embrace workflows properly. Around 
this time, Github released Github Actions [@gha] (referred from this 
point on as GHA), a workflow language and code execution platform. The 
GHA workflow language is a subset of the Hashicorp Configuration 
Language (HCL) [@hcl] a popular configuration language used in the 
DevOps community [@terraform]. The GHA language is one of the simplest 
workflow formats available. Simplicity in this context being defined 
in terms of the number of syntactic elements of the language. This 
makes it a great candidate language for users to implement workflows 
in multiple domains, as the language assumes a containerized 
environment.

In the remaining of this section we briefly introduce the GHA workflow 
language, as well as design and implementation of Popper 2.0 (the 
workflow execution engine). In particular, we dive into the pluggable 
container runtime component of the engine.

## Github Actions Workflow Language

The GHA language is an (open) workflow specification based on 
containers [@gha]. Being a workflow language, it specifies a set of 
tasks and the order in which they should be executed. An example is 
shown in @Fig:casestudy. A `.workflow` file is made of only two 
syntactical components: `workflow` and `action` blocks, with either 
having attributes associated to them. In the case of a `workflow` 
block, there's only a single attribute (`resolves`) that specifies the 
list of actions that are to be executed at the end of the workflow. 
Action blocks define the nodes in the workflow DAG, with a `needs` 
attribute denoting dependencies among actions, and a `uses` attribute 
specifying the container that is to be executed. The `uses` attribute 
can reference Docker images hosted in container image registries; 
filesystem paths for actions defined locally; or publicly accessible 
github repositories that contain actions (see [@] for a more detailed 
description).

In practical terms, an action is a container image that is expected to 
behave in a constrained manner. In particular, the logic within an 
action has to assume that it is given access to the project directory 
(the "workspace") where the workflow file is stored and that relative 
paths are with respect to this workspace folder. In addition, 
environment variables defined at runtime allow an action to access 
environmental information such as the absolute path to the workflow on 
the machine the workflow is running, the commit in the associated Git 
repository storing the `.workflow` file, among others. One of the 
greatest advantages of this one-container-per-action approach is that, 
given that the GHA specification is open, anyone can implement actions 
and publish them on Git repositories, allowing others to reuse them in 
distinct contexts, creating a bast ecosystem that researchers have 
available to them; anything from installing python packages, to 
configuring infrastructure, to manage datasets in data repositories.

## Execution engine

Popper is Container runtime abstraction. This component

## Container runtime plugins

Custom container configuration.

# Case Study {#sec:study}

We now present a case study that exemplifies how to follow the SciOps 
principles presented earlier[^available]. The example shows an 
end-to-end workflow corresponding to a parameter sweep execution of 
the NormalModes software package [@shi_computing_2018] from the SC19 
Student Cluster Competition Reproducibility Challenge 
[@michael_sc_2019].

![An end-to-end example of a workflow. On the left we have the 
`main.workflow` file that defines the actions in the workflow. To the 
left we have a pictorials representation of what the workflow is 
doing.
](./figures/casestudy.pdf){#fig:casestudy}

This workflow (@Fig:casestudy) goes through the stages of downloading 
the dataset from Zenodo, installing the code associated to the study, 
running the parameter sweep, producing output graphs, and validating 
claims that are made in the original study. This experimentation 
pipeline is specified in the Github Actions Workflow Language, an open 
format for defining workflows. All the principles outlined in the 
previous section are followed when implementing this workflow.

[^available]: Code available at <https://github.com/popperized/normalmodes-workflows>

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

  * Cultural: this is a DevOps-like workflow that requires a new 
    paradigm for implementing workflows.
  * Containers: not everybody can like them.
  * Instability: container technology is moving fast.

# Related Work {#sec:related}

  * docker-compose
  * workflow languages: commonwl, nextflow
  * kubernetes-based workflow engines: pachyderm, argo
  * container-based package managers: snap, flatpack and appimage

# Bibliography {.unnumbered}

<!-- hanged biblio -->

\noindent
\vspace{-2em}
\setlength{\parindent}{-0.26in}
\setlength{\leftskip}{0.2in}
\setlength{\parskip}{8pt}
