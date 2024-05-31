provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
   cidr_block = var.cidr_block

}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "sub1" {
   vpc_id = aws_vpc.myvpc.id
   cidr_block = "10.0.0.0/24"
   availability_zone = "us-east-1a"
}


resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.myvpc.id
}


resource "aws_route_table" "RT" {
   vpc_id = aws_vpc.myvpc.id

route{
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_nat_gateway.nat.id
}
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_eip" "nat_eip" {
    instance = aws_instance.webserver1.id
    domain   = "vpc"
     
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "main-nat"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "rt1" {
   subnet_id = aws_subnet.public_subnet.id
   route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "rt2" {
   subnet_id = aws_subnet.sub1.id
   route_table_id = aws_route_table.private.id
}


resource "aws_security_group" "sg" {
    name = "websg"
    vpc_id = aws_vpc.myvpc.id

ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
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

resource "aws_security_group" "db_sg" {
  name_prefix = "db-sg"
  description = "Allow PostgreSQL traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_acl" "main_acl" {
  vpc_id = aws_vpc.myvpc.id

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22 
    to_port    = 22
  }
}

resource "aws_security_group" "bastion_sg" {
  name_prefix = "bastion-sg"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion_host" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  security_groups        = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_instance" "webserver1" {
   ami = var.ami
   instance_type = var.instance_type
   vpc_security_group_ids = [aws_security_group.sg.id]
   subnet_id = aws_subnet.public_subnet.id
   user_data = file("${path.module}/userdata.sh")

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./abc.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
  inline = [
    "sudo yum -y update",
    "sudo yum -y install httpd",
   
    "sudo systemctl start httpd",
    "sudo systemctl enable httpd"
  ]
}
}

resource "aws_instance" "db" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.sub1.id
  security_groups = [aws_security_group.db_sg.name]

  tags = {
    Name = "db-instance"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./abc.pem")
    host        = aws_instance.db.private_ip
  }

  provisioner "remote-exec" {
   inline = [
    "sudo yum -y update",
    "sudo yum -y install postgresql postgresql-server",
    "sudo postgresql-setup initdb",
    "sudo systemctl start postgresql",
    "sudo systemctl enable postgresql"
  
  ]
}
}

resource "aws_lb" "ex_ALB" {

  name               = "albserver"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id] 
  subnets            = [aws_subnet.public_subnet.id]  

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