module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}
module "sg" {

  source = "./modules/security-group"

  vpc_id = module.vpc.vpc_id
}

data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"]

    filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "ec2" {

  source = "./modules/ec2"

  ami = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  subnet_id = module.vpc.subnet_id

  sg_id = module.sg.sg_id

  key_name = var.key_name

  root_volume_size = var.root_volume_size

  root_volume_type = var.root_volume_type
}