resource "aws_security_group" "ec2" {
  name_prefix = "ec2-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Or your ALB security group
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Or your ALB security group
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["93.118.41.101/32"] # Or your bastion host security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "web-lt-"
  image_id      = "ami-05b10e08d247fb927" # Replace with your AMI ID
  instance_type = "t2.micro"
  key_name = "" # replace with your key pair name
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = base64encode(<<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install -y nginx
  echo "<h1>Hello from EC2!</h1>" | sudo tee /var/www/html/index.html
  sudo systemctl start nginx
  EOF
  )
}

resource "aws_autoscaling_group" "web" {
  name_prefix          = "web-asg-"
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  vpc_zone_identifier  = var.private_subnet_ids
  desired_capacity     = 2
  min_size             = 1
  max_size             = 4
  target_group_arns = [aws_lb_target_group.web.arn]
}

resource "aws_lb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id] # Create this security group
  subnets            = var.public_subnet_ids
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_target_group" "web" {
  name_prefix = "web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "alb-sg-"
  vpc_id = var.vpc_id

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