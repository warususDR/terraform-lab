resource "aws_key_pair" "deployer" {
  key_name   = "terraform-key"
  public_key = file(var.public_key_path)
}

# security groups

resource "aws_security_group" "web_sg" {
  name        = "web_server_sg"
  description = "Allow HTTP/HTTPS and SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
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

resource "aws_security_group" "app_sg" {
  name        = "app_server_sg"
  description = "Allow 8080 from Web Server only"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "App Port from Web Server"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# instances

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.nano"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = { Name = "web_server" }
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.nano"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = { Name = "app_server" }
}

# domain and DNS

resource "aws_route53_zone" "subdomain" {
  name = "terraform.${var.domain_name}"
}

resource "cloudflare_dns_record" "ns_delegation" {
  count   = 4 
  
  zone_id = var.cloudflare_zone_id
  name    = "terraform" 
  content = aws_route53_zone.subdomain.name_servers[count.index]
  type    = "NS"
  proxied = false
  ttl     = 1
}

resource "aws_route53_record" "web" {
  zone_id = aws_route53_zone.subdomain.zone_id
  name    = "web.${aws_route53_zone.subdomain.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web.public_ip]
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.subdomain.zone_id
  name    = "app.${aws_route53_zone.subdomain.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.app.public_ip]
}