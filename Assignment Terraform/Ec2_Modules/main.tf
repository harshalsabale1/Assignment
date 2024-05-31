provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
   cidr_block = var.cidr_block

    tags = {
    Name = "MyPrivateVPC"
  }
}

resource "aws_subnet" "private" {
   vpc_id = aws_vpc.myvpc.id
   cidr_block = var.cidr_block
   availability_zone = "us-east-1b"
}

resource "aws_route_table" "private" {
   vpc_id = aws_vpc.myvpc.id

     tags = {
    Name = "PrivateRouteTable"
  }
}

resource "aws_route_table_association" "private_subnet" {
   subnet_id = aws_subnet.private.id
   route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "sg" {
    name = "web-app-sg"
    vpc_id = aws_vpc.myvpc.id

ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

 ingress {
    from_port   = 443
    to_port     = 443
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
   Name = "WebAppsg"
}
}

resource "aws_security_group" "db_sg" {
  name_prefix = "db-sg"
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

    tags = {
    Name = "DatabaseSG"
  }
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
  
}


resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "private_key" {

  content = tls_private_key.rsa.private_key_pem
  filename = var.key_name
  
}

resource "aws_instance" "webserver1" {
   ami = var.ami
   instance_type = var.instance_type
   vpc_security_group_ids = [aws_security_group.sg.id]
   subnet_id = aws_subnet.private.id
   key_name = aws_key_pair.key_pair.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y nodejs npm
              # Your commands to set up the Node.js or Flask app
              EOF

              tags = {
    Name = "WebAppInstance"
  }

}

resource "aws_instance" "db" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.db_sg.id]
  key_name = aws_key_pair.key_pair.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y postgresql postgresql-contrib
              # Your commands to set up PostgreSQL
              EOF

  tags = {
    Name = "db-instance"
  }

}

resource "aws_lb" "ex_ALB" {

  name               = "albserver"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id] 
  subnets            = [aws_subnet.private.id]  

  tags = {
    Name = "albserver"
  }
}

resource "aws_lb_target_group" "ex_tg" {

  name     = "TG1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  tags = {
    Name = "WebAppTargetGroup"
  }
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

resource "aws_lb_target_group_attachment" "web_app_target_attachment" {
  target_group_arn = aws_lb_target_group.ex_tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}



# Bastion Host Security Group

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
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

# Internal Instances Security Group

resource "aws_security_group" "internal_sg" {
  name        = "internal_sg"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# Define a Network ACL

resource "aws_network_acl" "main_acl" {
  vpc_id = aws_vpc.myvpc.id

  egress {
    rule_no    = 100
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    action = "allow"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    action = "allow"
    from_port  = 0
    to_port    = 0
  }
}

# Associate Network ACL with Subnets

resource "aws_network_acl_association" "main_acl_association" {
  subnet_id     = aws_subnet.private.id
  network_acl_id = aws_network_acl.main_acl.id
}

# Bastion Host

resource "aws_instance" "bastion" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.key_pair.key_name
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.bastion_sg.name]

  tags = {
    Name = "BastionHost"
  }
}

# Internal Instance

resource "aws_instance" "internal_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "my_key_pair_name"
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.internal_sg.name]

  tags = {
    Name = "InternalInstance"
  }
}
