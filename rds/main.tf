resource "aws_db_subnet_group" "main" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "rds-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306 # MySQL port
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "main" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  db_name              = "mydb"
  username             = "admin"
  password             = data.aws_secretsmanager_secret_version.rds_creds.secret_string
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot  = true
  multi_az = true
  identifier = "web-application-db"
}

resource "aws_secretsmanager_secret" "rds_creds" {
  name = "rds_credentials"
}

resource "aws_secretsmanager_secret_version" "rds_creds" {
  secret_id     = aws_secretsmanager_secret.rds_creds.id
  secret_string = jsonencode({
    username = "admin",
    password = random_password.rds_password.result
  })
}

resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

data "aws_secretsmanager_secret_version" "rds_creds" {
  secret_id = aws_secretsmanager_secret.rds_creds.id
}