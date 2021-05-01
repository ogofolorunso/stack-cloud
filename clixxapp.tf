resource "aws_db_instance" "dev" {
    instance_class      = "db.t2.micro"
    name                = ""
    snapshot_identifier = "clixxdbsnap"
    username             = "wordpressuser"
    password             = "W3lcome123"
    skip_final_snapshot       = true
    availability_zone        = "us-east-1a"
    vpc_security_group_ids = [aws_security_group.web-sg.id]
    

    lifecycle {
    ignore_changes = [snapshot_identifier]
    }

    depends_on = [aws_instance.web]
}


## CREATE EC2 INSTANCE
## ADD SECURITY GROUP
## ADD TAGS
## ATTACH KEY-NAME
## ATTACH BOOTSTRAP SCRIPT FOR WORDPRESS
resource "aws_instance" "web" {
    ami           = var.AMIS["us-east-1"]
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    user_data = templatefile("clixxapp/clix-bootstrap.sh", {
        MOUNT_POINT="/var/www/html",
        REGION = var.AWS_REGION,
        FILE_SYSTEM_ID = aws_efs_file_system.ogo.id,
        DATABASE_NAME = var.DATABASE_NAME,
        DB_USERNAME = var.DB_USERNAME,
        RDS_ENDPOINT = var.AWS_RDS_ENDPOINT,
        RDS_PASSWORD = var.RDS_PASSWORD

        })
    security_groups = [ "tf-security14" ]
    depends_on = [aws_efs_mount_target.alpha]
    key_name = var.PATH_TO_PRIVATE_KEY
    iam_instance_profile = "S3-Admin-Role"


    tags = {
    Name = "TF--EC2"
    }
}

#Create an EFS File System
resource "aws_efs_file_system" "ogo" {
    encrypted = true
    throughput_mode = "bursting"
    tags = {
        Name = "TF-EFS"
    }
}

#Setup Mount Target
resource "aws_efs_mount_target" "alpha" {
    file_system_id = aws_efs_file_system.ogo.id
    subnet_id = var.my_aws_subnet["us-east-1a"]
    security_groups = [aws_security_group.web-sg.id]
}

##CREATE SECURITY GROUP AND ADD DIFFERENT PORTS
resource "aws_security_group" "web-sg" {
    name = "tf-security141"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port  = 22
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 2049
        to_port     = 2049
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 3306
        to_port     = 3306
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

/*
#CREATING AN AUTOSCALING GROUP
resource "aws_launch_configuration" "test_configg" {
    name_prefix   = "terraform-launch-config1"
    image_id      = var.AMIS["us-east-1"]
    instance_type = "t2.micro"
    security_groups = [aws_security_group.web-sg.id]
    key_name = var.PATH_TO_PRIVATE_KEY
}
    

resource "aws_autoscaling_group" "tf" {
    name                 = "terraform-ogo-example14"
    launch_configuration = aws_launch_configuration.test_configg.name
    min_size             = 0
    max_size             = 0
    health_check_grace_period = 300
    health_check_type         = "EC2"
    desired_capacity          = 0
    force_delete              = true
    vpc_zone_identifier       = [
        var.my_aws_subnet["us-east-1a"],
        var.my_aws_subnet["us-east-1b"],
        var.my_aws_subnet["us-east-1c"]
        ]
    tag {
        key                 = "Name"
        value               = "TF-ASG"
        propagate_at_launch = true
    }
}
*/

/*
terraform{
        backend “s3”{
                bucket= “Stackbuckstate[yourname]”
                key = “terraform.tfstate”
                region=”us-east-1”
                }
}
*/




/*
##CREATING AN SSH KEY
resource "aws_key_pair" "ssh_key" {
    key_name   = "Ogo-TF-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}
*/