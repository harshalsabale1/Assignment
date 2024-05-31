module "MyEc2" {
    source = "./Ec2_Modules"
    ami = var.ami
    instance_type = var.instance_type
    cidr_block = var. cidr_block
}