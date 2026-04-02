data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

provider "aws" {
    region = var.region
}

resource "aws_vpc" "techcorp_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "techcorp_vpc"
    }
}

# Public subnet 1
resource "aws_subnet" "public_1" {
    vpc_id = aws_vpc.techcorp_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "${var.region}a"
    map_public_ip_on_launch = true

    tags = {
        Name = "techcorp-public-subnet-1"
    }
}

# Public subnet 2
resource "aws_subnet" "public_2" {
    vpc_id = aws_vpc.techcorp_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "${var.region}b"
    map_public_ip_on_launch = true

    tags = {
        Name = "techcorp-public-subnet-2"
    }
}

# Private subnet 1
resource "aws_subnet" "private_1" {
    vpc_id = aws_vpc.techcorp_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "${var.region}a"

    tags = {
        Name = "techcorp-private-subnet-1"
    }
}

# Private subnet 2
resource "aws_subnet" "private_2" {
    vpc_id = aws_vpc.techcorp_vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "${var.region}b"

    tags = {
        Name = "techcorp-private-subnet-2"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.techcorp_vpc.id

    tags = {
        Name = "techcorp-igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.techcorp_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "techcorp-public-rt"
    }
}

resource "aws_route_table_association" "public_1_assoc" {
    subnet_id = aws_subnet.public_1.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2_assoc" {
    subnet_id = aws_subnet.public_2.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip_1" {
    domain = "vpc"
}

resource "aws_eip" "nat_eip_2" {
    domain = "vpc"
}

resource "aws_nat_gateway" "nat_1" {
    allocation_id = aws_eip.nat_eip_1.id
    subnet_id = aws_subnet.public_1.id

    tags = {
        Name = "nat-gateway-1"
    }
}

resource "aws_nat_gateway" "nat_2" {
    allocation_id = aws_eip.nat_eip_2.id
    subnet_id = aws_subnet.public_2.id

    tags = {
        Name = "nat-gateway-2"
    }
}

# Private RT 1
resource "aws_route_table" "private_rt_1" {
    vpc_id = aws_vpc.techcorp_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_1.id
    }

    tags = {
        Name = "private_rt_1"
    }
}

# Private RT 2
resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }

  tags = {
    Name = "private-rt-2"
  }
}

resource "aws_route_table_association" "private_1_assoc" {
    subnet_id = aws_subnet.private_1.id
    route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_route_table_association" "private_2_assoc" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt_2.id
}

resource "aws_security_group" "bastion_sg" {
    name = "bastion_sg"
    description = "Allow SSh from my IP"
    vpc_id = aws_vpc.techcorp_vpc.id

    ingress {
        description = "SSH from my IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "bastion_sg"
    }
}

resource "aws_security_group" "web_sg" {
    name = "web-sg"
    vpc_id = aws_vpc.techcorp_vpc.id

    #HTTP
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }

    #HTTPS
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # SSH from bastion server Only
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion_sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "db_sg" {
    name = "db-sg"
    vpc_id = aws_vpc.techcorp_vpc.id

    # Postgress from Web Only
    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.web_sg.id]
    }

    #SSH from Bastion Only
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion_sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.techcorp_vpc.id

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type_bastion
    subnet_id = aws_subnet.public_1.id
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.bastion_sg.id]

    associate_public_ip_address = true

    tags = {
        Name = "bastion-host"
    }
}

resource "aws_eip" "bastion_eip" {
    instance = aws_instance.bastion.id
    domain = "vpc"
}

resource "aws_instance" "web_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type_web
  subnet_id              = aws_subnet.private_1.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = file("user_data/web_server_setup.sh")

  depends_on = [aws_nat_gateway.nat_1]

  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "web_2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type_web
  subnet_id              = aws_subnet.private_2.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = file("user_data/web_server_setup.sh")

  depends_on = [aws_nat_gateway.nat_2]

  tags = {
    Name = "web-server-2"
  }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type_db
  subnet_id              = aws_subnet.private_2.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  user_data = file("user_data/db_server_setup.sh")

  tags = {
    Name = "db-server"
  }
}

resource "aws_lb_target_group" "web_tg" {
    name = "web-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.techcorp_vpc.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_target_group_attachment" "web1" {
    target_group_arn = aws_lb_target_group.web_tg.arn
    target_id = aws_instance.web_1.id
    port = 80
}

resource "aws_lb_target_group_attachment" "web2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id = aws_instance.web_2.id
  port = 80
}

resource "aws_lb" "app_lb" {
  name               = "techcorp-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_sg.id]
  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  tags = {
    Name = "techcorp-alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}