module "MyEc2" {
    key_name = "my_key_pair_name"
    source = "./Ec2_Modules"
    ami = var.ami
    instance_type = var.instance_type
    public_subnet_cidr = var.public_subnet_cidr
    private_subnet_cidr = var.private_subnet_cidr
}