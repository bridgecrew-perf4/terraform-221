# Terraform

## What is Terraform

- Terraform is an open-source IAC software tool by Hashicorp that provides a consistent CLI workflow to manage hundreds of cloud services
- Terraform codifies cloud APIs into declarative configuration files

## Why Terraform

- Allows to efficiently scale up/down to meet user demand
- As Terraform uses declarative configuration files, it is cloud-independent, i.e.  it works with AWS, GCP, Azure allowing for multi-cloud configuration

### Best Use Cases

**Other IAC Tools**

- Orchestration with Terraform
- From an AMI to EC2 instance with customised configuration


## Using Terraform

- File extensions are .tf
- Language used is HCL, similar to JSON in syntax

**Commands**

- ``terraform init`` to initialise terraform
- ``terraform plan`` to plan
    - **Terraform will look for the keys stored as environment variables**
    - provides a summary of instances to add, change, and destroy
- ``terraform apply`` to run the .tf file
