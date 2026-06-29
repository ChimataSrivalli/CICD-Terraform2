resource "aws_instance" "jenkins" {

  ami = var.ami

  instance_type = var.instance_type

  subnet_id = var.subnet_id

  vpc_security_group_ids = [var.sg_id]

  key_name = var.key_name

  user_data = file("${path.module}/install.sh")
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }
}  