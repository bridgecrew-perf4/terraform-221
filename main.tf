# Cloud provider required, in this case using AWS
provider "aws" {
	region = var.region
}

module myip {
	source = "4ops/myip/http"
	version = "1.0.0"
}

module "vpc" {
    source = "./modules/m_vpc"

    my_ip = module.myip.address
}

module "sg" {
    source = "./modules/m_sg"

    vpc_id = module.vpc.vpc_id
    my_ip = module.myip.address
}

module "app" {
    source = "./modules/m_app"

    ami_nodejs = var.ami_nodejs
    public_subnet_id = module.vpc.public_subnet_id
    instance_type = var.instance_type
    nodejs_sg_id = module.sg.nodejs_sg_id
    mongodb_private_ip = module.db.mongodb_private_ip
    aws_key_name = var.aws_key_name
    aws_key_path = var.aws_key_path
}

module "db" {
    source = "./modules/m_db"

    ami_mongo = var.ami_mongo
    private_subnet_id = module.vpc.private_subnet_id
    instance_type = var.instance_type
    mongodb_sg_id = module.sg.mongodb_sg_id
    aws_key_name = var.aws_key_name
}