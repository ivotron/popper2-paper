---
title: "Popper 2.0: A Multi-container Workflow Execution Engine For Testing Complex Applications and Validating Scientific Explorations"
author: Ivo Jimenez, Jayjeet Chakraborty, Arshul Mansoori, Quincy Wofford and Carlos Maltzahn
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

Thus, we would like to break workflows into subunits, having one 
container image per node in the directed acyclic graph (DAG) 
associated to the workflow. From the point of view of UX design, this 
opens the possibility for devising languages to express 
multi-container workflows such as the ones implemented in application 
testing and scientific study validation.

<!-- Singularity is targeted at HPC use cases [@singularity]. -->

# Popper 2.0

The goal of the Popper project [@jimenez_popper_2017] is to aid users 
in the implementation of workflows following a DevOps approach. Last 
year, the Popper team released version 1.0 of the command line tool, 
which allows users to specify workflows in a lightweight YAML syntax. 
In Popper 1.0, the nodes in a workflow DAG represent arbitrary Bash 
shell commands, leaving the burden of ensuring that this commands are 
portable to users. Additionally, as the project team kept 
incorporating user feedback, the YAML-based workflow definition syntax 
kept evolving and, over time, started to look like a workflow 
specification. Thus the team decided it was time to embrace workflows 
properly. Around this time, Github released Github Actions 
[@github_github_2018] (referred from this point on as GHA), a workflow 
language and code execution platform. The GHA workflow language is a 
subset of the HashiCorp Configuration Language (HCL)[^hcl], a popular 
configuration language used in the DevOps community 
[@brikman_terraform_2017]. The GHA workflow language is one of the 
simplest workflow formats available; simplicity in this context being 
defined in terms of the number of syntactic elements of the language. 
This characteristic, along with the fact that the language 
specification assumes a containerized environment, made the GHA 
workflow language a great option for implementing Popper version 2.0.

[^hcl]: <https://github.com/hashicorp/hcl>

In the remaining of this section we briefly expand on the GHA workflow 
language, as well as the design and implementation of the workflow 
execution engine (Popper 2.0); in particular, we dive into the 
container runtime API layer.

## Github Actions Workflow Language

The GHA language is an (open) workflow specification based on 
containers [@github_open_2019]. Being a workflow language, it 
specifies a set of tasks and the order in which they should be 
executed. An example is shown in @Fig:casestudy. A `.workflow` file is 
made of only two syntactical components: `workflow` and `action` 
blocks, with either having attributes associated to them. In the case 
of a `workflow` block, there's only a single attribute (`resolves`) 
that specifies the list of actions that are to be executed at the end 
of the workflow. Action blocks define the nodes in the workflow DAG, 
with a `needs` attribute denoting dependencies among actions, and a 
`uses` attribute specifying the container that is to be executed. The 
`uses` attribute can reference Docker images hosted in container image 
registries; filesystem paths for actions defined locally; or publicly 
accessible github repositories that contain actions [^gha-docs].

[^gha-docs]: See <https://developer.github.com/actions> for more.

In practical terms, an action is a container image that is expected to 
behave in a constrained manner. The logic within an action has to 
assume that it is given access to the project directory (the 
"workspace") where the workflow file is stored and that relative paths 
are with respect to this workspace folder. In addition, environment 
variables defined at runtime allow an action to access environmental 
information such as the absolute path to the workflow on the machine 
the workflow is running, the commit in the associated Git repository 
storing the `.workflow` file, among others. One of the greatest 
advantages of this one-container-per-action approach is that, given 
that the GHA specification is open, anyone can implement actions and 
publish them on Git repositories, allowing others to reuse them in 
distinct contexts, creating a bast catalog of actions; anything from 
installing python packages, to configuring infrastructure, to manage 
datasets in data repositories.

![Architecture of the Popper workflow execution engine
](./figures/architecture.pdf){#fig:arch}

## Workflow Execution Engine

The architecture of the Popper GHA workflow execution engine is shown 
in @Fig:arch. The source code is available at 
<https://github.com/systemslab/popper>, released with an open source 
license. Users interact with the execution engine via its command line 
interface (CLI). They provide a `.workflow` file and optionally a 
runtime configuration file. The engine has three main components:

### **Command line interface (CLI)**

Besides allowing users to execute workflows, the CLI provides with 
search capabilities so that users can search for existing actions 
implemented by others; allows to visualize workflows by generating 
diagrams such as the one shown in @Fig:casestudy; generates 
configuration files for continuous integration systems (e.g. TravisCI, 
Jenkins, Gitlab-CI, etc.) so that users can continuously validate the 
workflows they implement.

### **Workflow runner**

The workflow runner is in charge of parsing the `.workflow` file and 
creating an internal representation for it. It also downloads actions 
referenced by the workflow, and routes the execution of an action to 
its corresponding runtime plugin. The runner also creates a cache 
directory to optimize multiple aspects of execution such (e.g. avoid 
cloning repositories if they have already cloned previously).

### **Container runtime API and plugins**

This component abstracts the runtime from the. The API exposes generic 
operations that all runtimes support such as creating a container 
image from a `Dockerfile`; downloading images from a registry and 
converting them to their internal format; and operations on containers 
such as creation, deletion, renaming, etc. Currently, there are 
plugins for Docker and Singularity, with others planned by the Popper 
community.

In addition, the container runtime abstraction layer supports the 
specialization of a runtime by allowing users to provide a 
runtime-specific configuration file. This enables users to take 
advantage of runtime-specific features in a transparent way. For 
example, in the case of Singularity, this file can contain 
specific information about the batch scheduler, such that 
a container can connect to it and launch MPI jobs. This file can 
either be created by users or be provided by system 
administrators.

# Case Study {#sec:study}

We now present a case study that exemplifies how to create a workflow 
as part of a scientific exploration[^available]. The example shows an 
end-to-end workflow corresponding to a parameter sweep execution of 
the NormalModes software package [@shi_computing_2018] from the SC19 
Student Cluster Competition (SCC) Reproducibility Challenge 
[@michael_sc_2019]. This workflow (@Fig:casestudy) goes through the 
stages of downloading input datasets, building the code associated to 
the study, running the parameter sweep, validating claims that are 
made in the original study and producing visualizations of the output.

In the context of the SCC Reproducibility Challenge, having a fully 
functional workflow upfront reduces significantly the barrier for 
students to begin being productive. Given that the purpose of the SCC 
is to have students optimize as much as possible the code for a 
particular platform, having fully functional end-to-end workflow 
allows them to focus right away on what it matters (optimizing 
compilation, swapping libraries, etc.). Compare this to the 
alternative scenario where students need to start from a tarball and a 
`README` file; much of the time in this scenario is spent on tasks 
that do not provide value to their final goal.

[^available]: Code available at 
<https://github.com/popperized/normalmodes-workflows>

# Discussion {#sec:discuss}

## Benefits

### **Tool suitability**

Fits well the researcher workflow: shell/python/R scripts are still 
used. Dockerfiles allow them to specify how their environment looks 
like and GHA allows them to reuse as much as possible.

### **Workflow portability**

From the point of view of users, given that `Dockerfile`s are 
"universal" (all runtimes support it), a GHA workflow can serve as an 
abstraction between them and the multitude of runtimes available to 
them. For example, GHA workflows can be the bridge between HPC and 
cloud infrastructures. The roadmap of Popper envisions executing 
seamlessly on Kubernetes by handling all the logic of deploying a 
scheduler under the hood, or connecting the application to an existing 
Kubernetes-hosted batch scheduler. This means that from the point of 
view of a user, they can run the same workflow regardless of the 
backend infrastructure.

### **User friendliness**

An extension of the above; container-based workflow language such as 
GHA hides complexities and runtime-specific setups of a container 
container runtime. The researcher or developer sees `Dockerfile` and 
`.workflow` files; system administrators configure the runtime and 
provide a configuration file that users pass to Popper (e.g. GPU, 
batch schedulers, etc.).

## Challenges

### **Technological barriers**

Software containers, being a relatively new technology, can be seen a 
significant time investment given its associated learning curve.

### **Cultural barriers**

Carrying out experimentation or complex application testing by writing 
workflows is not something practitioners are used to do; following 
this approach requires a paradigm shift.

### **Security and stability concerns**

Container technology is currently moving relatively fast, with new 
versions of container runtimes being released every week. In some 
contexts this might be a deal breaker, as this represents a burden 
from the point of view of system administrators.

# Related Work {#sec:related}

The problem of implementing multi-container workflows as described in 
@Sec:intro is addressed by existing tools. We briefly survey some of 
these technologies and compare them with Popper 2.0 by grouping them 
in categories.

### **Workflow languages**

Workflow languages such as CommonWL [@amstutz_common_2016] and Yadage 
[^yadage] allow users to specify workflows using a standard, 
runtime-agnistic language that can be implemented by multiple engines. 
These languages do not assume a containerized environment, although 
they support container-based workflows. Compared to the GHA language, 
their syntax is more complex and give users more control over 
execution aspects (e.g. specify scheduling policies).

### **Kubernetes-based**

A set of workflow engines that run on Kubernetes, each having their 
own syntax, allow users to easily submit workflows to a Kubernetes 
cluster (assuming they have access to one). Examples of these are 
Pachyderm [@novella_containerbased_2018], Argo[^argo] and 
Brigade[^brigade]. The main drawback of these when compared to Popper 
is that the requirement of having access to a Kubernetes cluster.

### **Scientific workflow engines**

Stable and mature scientific workflow engines such as Pegasus 
[@deelman_pegasus_2004], Taverna [@oinn_taverna_2004] and NextFlow 
[@ditommaso_nextflow_2017] have introduced native support for 
containers. Similarly, these impose the requirement of needing a 
workflow engine deployment prior to being able to execute workflows.

### **Container-based package managers**

While not proper workflow execution engines, container-based package 
managers such as category Snappy[^snappy], Flatpack[^flatpack] and 
AppImage[^appimage] can be employed to implement reproducible 
workflows. This alternative does not require users to specify their 
workflows using a workflow language (shell scripts suffice), but 
assumes that these package managers are available in the Host OS.

[^argo]: <https://github.com/argoproj/argo>
[^snappy]: <https://github.com/snapcore/snapd>
[^flatpack]: <https://github.com/flatpak/flatpak>
[^appimage]: <https://github.com/AppImage/AppImageKit>
[^yadage]: <https://github.com/yadage/yadage>
[^brigade]: <https://brigade.sh>

# Bibliography {.unnumbered}

<!-- hanged biblio -->

\noindent
\vspace{-2em}
\setlength{\parindent}{-0.26in}
\setlength{\leftskip}{0.2in}
\setlength{\parskip}{8pt}
