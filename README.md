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

### Commands

- ``terraform init`` to initialise terraform
    - terraform will detect which necessary modules/plugins to download first
- ``terraform validate`` to assess if configuration is valid
- ``terraform plan`` to plan
    - provides a summary of instances to add, change, and destroy
- ``terraform apply`` to run the .tf file
- ``terraform destroy`` to destroy Terraform-managed infrastructure



### Provider

Specify the cloud provider to build instances on
```
provider "aws" {
	region = "eu-west-1"
}
```
There is no need to specify access/secret keys, **Terraform will look for the keys stored as environment variables**

### Resources

Resources are the most important element in the Terraform language

Each resource block describes one or more infrastructure objects, such as
- virtual networks
- compute instances
- higher-level components such as DNS records

A ``resource`` block declares a resource of a given type, and a given local name which can be used to refer to the resource from elsewhere in the same Terraform module

The resource type and name together serve as an identifier for a given resource and so must be unique within a module

### Security Groups

Security groups can be created with the resource ``aws_security_group`` specifying:
- 2nd argument as the resource name for future reference in the terraform file
- name
- description
- VPC id
- Ingress (Inbound)/Egress (Outbound) rules
    - Either CIDR blocks or security groups can be specified to identify sources
- tags
```
resource "aws_security_group" "mongo_access"{
	name = "eng74-leo-terra-mongo-access"
	description = "Allow traffic on port 27017 for mongoDB"
	vpc_id = "vpc-07e47e9d90d2076da"

	ingress {
		description = "27017 from app instance"
		from_port = 27017
		to_port = 27017
		protocol = "tcp"
		security_groups = ["sg-09daa57de1874642a"]
	}

	egress {
		description = "All traffic out"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]

	}

	tags = {
		Name = "eng74-leo-terra-mongo-access"
	}
}
```

### Instances

EC2 Instances can be created with the resource ``aws_instance`` specifying:
- 2nd argument as the resource name for future reference in the terraform file
- AMI
- Instance type
- key name (to allow SSH in)
- ``associate_public_ip_address`` set to true to allow remote access
- ``vpc_security_group_ids`` if the instances are being created within a VPC then these must be used to specify security groups
- tags
```
resource "aws_instance" "mongodb_instance" {
	ami = "ami-03646b6976790491d"
	instance_type = "t2.micro"
	key_name = "eng74_leo_aws_key"
	associate_public_ip_address = true
	vpc_security_group_ids = [aws_security_group.mongo_access.id]
	tags = {
		Name = "eng74-leo-terraform-db"
	}
}
```

**Running Shell Commands**

Shell commands can be ran with the provisioner ``remote-exec``, but first a connection must be specified first to allow SSHing in, specifying:
- Connection type
- User
- Private key location
- Host to connect to
```
connection {
		type = "ssh"
		user = "ubuntu"
		private_key = "${file("~/.ssh/eng74_leo_aws_key.pem")}"
		host = "${self.public_ip}"
	} 
```
Multiple commands can be specified as list arguments
```
provisioner "remote-exec"{
		inline = [
			"export DB_HOST=${aws_instance.mongodb_instance.private_ip}",
			"cd app/ && pm2 start app.js",
		]
	}
```