resource "aws_db_subnet_group" "aurora_subnet_group" {
    name       = "fiapx-aurora-subnet-group"
    subnet_ids = module.vpc.private_subnets

    tags = {
        Name = "fiapx-aurora-subnet-group"
    }
}

resource "aws_security_group" "aurora_sg" {
    name        = "fiapx-aurora-sg"
    description = "Security group for MySQL database"
    vpc_id      = aws_vpc.main.id

    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "fiapx-aurora-sg"
    }
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = "fiapx-aurora"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.04.0"
  database_name      = "video_processor_db"
  master_username    = "springuser"
  master_password    = var.db_password
  skip_final_snapshot = true

  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]

  storage_encrypted = true
  backup_retention_period = 7

  tags = {
    Name = "fiapx-aurora-cluster"
  }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier         = "fiapx-aurora-instance"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora_cluster.engine

  tags = {
    Name = "fiapx-aurora-instance"
  }
}

output "aurora_db_endpoint" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}
