variable "ami" {
   type = string
   default = "ami-00beae93a2d981137"
}

variable "instance_type" {
   type = string
   default = "t2.micro"
}

variable "cidr_block" {
   type = string
   default = "10.0.0.0/16"
}

variable "key_name" {
  
}