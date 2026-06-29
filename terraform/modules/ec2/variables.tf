variable "ami" {
  type = string
}
variable "instance_type" {
   type = string
}
variable "subnet_id" {
   type = string
}
variable "sg_id" {
   type = string
}
variable "key_name" {
  type = string
}
variable "root_volume_size" {
  type = number
}

variable "root_volume_type" {
  type = string
}