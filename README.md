# Terraform ACI

This repo contains a set of modules in the [modules folder](https://bitbucket.il2management.local/projects/NET/repos/terraform/browse/modules) for deploying an ACI system using [Terraform](https://www.terraform.io/).

Each system has its own directory to maintain configuration separation, while still being able to make use of the same shared modules.

## How to use this Module

This repo has the following folder structure:

* [modules](https://bitbucket.il2management.local/projects/NET/repos/terraform/browse/modules): This folder contains several standalone, reusable, production-grade modules that you can use to deploy ACI.
* [sys00003](https://bitbucket.il2management.local/projects/NET/repos/terraform/browse/sys00003): This defines the infrastructure in ACI system 3 that is managed by Terraform.
* [sys00015](https://bitbucket.il2management.local/projects/NET/repos/terraform/browse/sys00015): This defines the infrastructure in ACI system 15 that is managed by Terraform.