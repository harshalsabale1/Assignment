provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "myvpc" {
   cidr_block = var.cidr_block

}

resource "aws_subnet" "sub1" {
   vpc_id = aws_vpc.myvpc.id
   cidr_block = "10.0.0.0/24"
   availability_zone = "ap-south-1a"
   map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "RT" {
   vpc_id = aws_vpc.myvpc.id

route{
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
}
}

resource "aws_route_table_association" "rt1" {
   subnet_id = aws_subnet.sub1.id
   route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "sg" {
    name = "websg"
    description = "Allow TLS inbound traffic"
    vpc_id = aws_vpc.myvpc.id

ingress {
    description = "HTTP from VPC"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
}

tags = {
   Name = "websg"
}
}

  resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-unique-bucket-name"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


resource "aws_instance" "webserver1" {
   ami = var.ami
   instance_type = var.instance_type
   vpc_security_group_ids = [aws_security_group.sg.id]
   subnet_id = aws_subnet.sub1.id
   user_data = (file("userdata.sh"))
}

resource "aws_launch_configuration" "ex_LC" {

  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.sg.id]

}

resource "aws_autoscaling_group" "ex_ASG" {

  launch_configuration = aws_launch_configuration.ex_LC.name
  min_size             = 1
  max_size             = 5
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.sub1.id] 
}

resource "aws_lb" "ex_ALB" {

  name               = "albserver"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id] 
  subnets            = [aws_subnet.sub1.id] 

  tags = {
    Name = "albserver"
  }
}

resource "aws_lb_target_group" "ex_tg" {

  name     = "TG1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id
}


resource "aws_lb_listener" "ALB_listener" {

  load_balancer_arn = aws_lb.ex_ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ex_tg.arn
    type             = "forward"

  }
}
