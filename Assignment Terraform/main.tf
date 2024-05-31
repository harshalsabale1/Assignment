module "MyEc2" {
    key_name = "my_key_pair_name"
    source = "./Ec2_Modules"
    ami = var.ami
    instance_type = var.instance_type
    cidr_block = var. cidr_block
}