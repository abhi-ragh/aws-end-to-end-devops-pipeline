resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL access from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "rds-sg"
    Environment = "dev"
    Terraform   = "true"
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "nodeappdb"

  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0"
  major_engine_version = "8.0"

  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "nodeappdb"
  username = "admin"

  manage_master_user_password = true
  port                        = 3306

  multi_az               = true
  deletion_protection    = true
  skip_final_snapshot    = false
  publicly_accessible    = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  create_db_subnet_group = true
  subnet_ids             = module.vpc.database_subnets

  backup_retention_period = 7
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"

  monitoring_interval    = 30
  create_monitoring_role = true

  parameters = [
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  tags = {
    Name        = "nodeappdb"
    Environment = "dev"
    Terraform   = "true"
  }
}