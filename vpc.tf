# VPC resources: This will create 1 VPC with 8 Subnets, 1 Internet Gateway, 2 Route Tables. 

#Create VPC
resource "aws_vpc" "clixxvpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    tags = {
        Name = "ClixxVPC-TF"
    }
}

#Create Internet Gateway
resource "aws_internet_gateway" "clixx" {
    vpc_id = aws_vpc.clixxvpc.id
    tags = {
        Name = "ClixxIGW TF"
    }
}

#Create NAT Gateway
resource "aws_nat_gateway" "gw" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.Subnet_A["Public_Subnet_Subnet_A_TF"].id
}

# Create Elatic IP eip
resource "aws_eip" "nat" {
    vpc = true
}

#Create Route Table and association
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.clixxvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.gw.id 
    }
    tags = {
        Name = "Private_NATGW_Route_Table-TF"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.clixxvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.clixx.id 
    }
    tags = {
        Name = "Public_IGW_Route_Table-TF"
    }
}

#Associate route tablw with public subnet
resource "aws_route_table_association" "attach-public" {
    for_each = {
        "subnet1" = aws_subnet.Subnet_A["Public_Subnet_Subnet_A_TF"].id,
        "subnet2" = aws_subnet.Subnet_B["Public_Subnet_Subnet_B_TF"].id
    }
    
    subnet_id      = each.value
    route_table_id = aws_route_table.public.id
}

#Associate route table with private subnet
resource "aws_route_table_association" "attach-private" {
    for_each = {
        "subnet1" = aws_subnet.Subnet_A["ClixxApp_Private_Subnet_A_TF"].id,
        "subnet2" = aws_subnet.Subnet_B["ClixxApp_Private_Subnet_B_TF"].id,
        "subnet3" = aws_subnet.Subnet_A["RDS_Subnet_A_TF"].id,
        "subnet4" = aws_subnet.Subnet_B["RDS_Subnet_B_TF"].id,
        "subnet5" = aws_subnet.Subnet_A["Oracle_Subnet_Subnet_A_TF"].id,
        "subnet6" = aws_subnet.Subnet_B["Oracle_Subnet_Subnet_B_TF"].id
    }
    
    subnet_id      = each.value
    route_table_id = aws_route_table.private.id
}


##CREATE SECURITY GROUP
resource "aws_security_group" "pub-sg" {
    name = "Public_Subnet_SG_TF"
    vpc_id = aws_vpc.clixxvpc.id
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
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "clixpriv-sg" {
    name = "ClixxApp_Private_Subnet_SG_TF"
    vpc_id = aws_vpc.clixxvpc.id
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        description = "Allows hosts in LB to access server"
        security_groups = [aws_security_group.LB-sg.id]
    }
    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        description = "Allow resources in public subnet to ping to server"
        security_groups = [aws_security_group.pub-sg.id]
    }
    ingress {
        from_port = 22
        to_port  = 22
        protocol  = "tcp"
        description = "Allows Bastion server to ssh into clixx app for admin purposes"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    depends_on = [aws_security_group.pub-sg]

}

resource "aws_security_group" "LB-sg" {
    name = "Load_Balancer_SG_TF"
    vpc_id = aws_vpc.clixxvpc.id
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

resource "aws_security_group" "RDS-sg" {
    name = "RDS_SG_TF"
    vpc_id = aws_vpc.clixxvpc.id
    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        description = "Allows clixx app to connect with RDS"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "Oracle-sg" {
    name = "Oracle_Subnet_SG_TF"
    vpc_id = aws_vpc.clixxvpc.id
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


##Create Subnet in 2 Availability zones
resource "aws_subnet" "Subnet_A" {
vpc_id     = aws_vpc.clixxvpc.id
availability_zone = "us-east-1a"
for_each = {
    "Public_Subnet_Subnet_A_TF" = "10.0.2.0/23"
    "ClixxApp_Private_Subnet_A_TF" = "10.0.0.0/23"
    "RDS_Subnet_A_TF" = "10.0.4.0/22"
    "Oracle_Subnet_Subnet_A_TF" = "10.0.10.0/24"
}
cidr_block = each.value
tags = {
    Name = each.key
}
}

resource "aws_subnet" "Subnet_B" {
vpc_id     = aws_vpc.clixxvpc.id
availability_zone = "us-east-1b"
for_each = {
    "Public_Subnet_Subnet_B_TF" = "10.0.18.0/23"
    "ClixxApp_Private_Subnet_B_TF" = "10.0.16.0/23"
    "RDS_Subnet_B_TF" = "10.0.12.0/22"
    "Oracle_Subnet_Subnet_B_TF" = "10.0.11.0/24"
}
cidr_block = each.value
tags = {
    Name = each.key
}
}

#Create the Database from snapshot
resource "aws_db_instance" "dev" {
    instance_class      = "db.t2.micro"
    db_subnet_group_name = aws_db_subnet_group.clixx.id
    identifier                = "clixxvpcdbterraform"
    snapshot_identifier = "clixxdbsnap"
    username             = "wordpressuser"
    password             = "W3lcome123"
    skip_final_snapshot       = true
    #availability_zone        = "us-east-1a"
    vpc_security_group_ids = [aws_security_group.RDS-sg.id]
    

    lifecycle {
    ignore_changes = [snapshot_identifier]
    }

}

resource "aws_db_subnet_group" "clixx" {
    name       = "clixrds_subnet"
    subnet_ids = [aws_subnet.Subnet_A["RDS_Subnet_A_TF"].id, aws_subnet.Subnet_B["RDS_Subnet_B_TF"].id]

    tags = {
        Name = "My clixx RDSDB subnet group"
    }
}

#Create launch configuration for Autoscaling Group 
resource "aws_launch_configuration" "test_configg" {
    name_prefix   = "clix-launch-config-TF"
    image_id      = var.AMIS["us-east-1"]
    instance_type = "t2.micro"
    security_groups = [aws_security_group.clixpriv-sg.id]
    key_name = var.PATH_TO_PRIVATE_KEY
    user_data = templatefile("clix-bootstrap.sh", {
        DATABASE_NAME = var.DATABASE_NAME,
        DB_USERNAME = var.DB_USERNAME,
        #RDS_ENDPOINT = var.AWS_RDS_ENDPOINT,
        RDS_PASSWORD = var.RDS_PASSWORD,
        DB_HOST=aws_db_instance.dev.address,
        LB_DNS=aws_lb.test.dns_name
        })
    depends_on = [ aws_db_instance.dev]
}
    
#Creating an autoscaling group for EC2 App server
resource "aws_autoscaling_group" "tf" {
    name                 = "clixxASG"
    launch_configuration = aws_launch_configuration.test_configg.name
    min_size             = 1
    max_size             = 1
    health_check_grace_period = 300
    health_check_type         = "EC2"
    target_group_arns = [ aws_lb_target_group.clixxvpc.arn ]
    desired_capacity          = 1
    force_delete              = true
    vpc_zone_identifier       = [
        aws_subnet.Subnet_A["ClixxApp_Private_Subnet_A_TF"].id,
        aws_subnet.Subnet_B["ClixxApp_Private_Subnet_B_TF"].id
            ]
    tag {
        key                 = "Name"
        value               = "ClixxEC2-TF"
        propagate_at_launch = true
    }
}

#Creating a Bastion Server
resource "aws_instance" "web" {
    ami           = var.AMIS["us-east-1"]
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    subnet_id = aws_subnet.Subnet_A["Public_Subnet_Subnet_A_TF"].id
    associate_public_ip_address = "true"
    security_groups = [ aws_security_group.pub-sg.id ]
    key_name = var.PATH_TO_PRIVATE_KEY
    iam_instance_profile = "S3-Admin-Role"

    tags = {
        Name = "Bastion-TF"
    }
}

#Creating a Load Balancer
resource "aws_lb" "test" {
    name               = "clixxvpcloadbaltf"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.LB-sg.id]
    subnets            = [
        aws_subnet.Subnet_A["Public_Subnet_Subnet_B_TF"].id,
        aws_subnet.Subnet_B["Public_Subnet_Subnet_A_TF"].id
            ]
    enable_deletion_protection = false

    tags = {
        Environment = "TF-LB"
    }
}

#Create a LB TARGET GROUP
resource "aws_lb_target_group" "clixxvpc" {
    name     = "LB-targetgroup-EF"
    port     = 80
    protocol = "HTTP"
    health_check { path = "/index.php" }
    vpc_id   = aws_vpc.clixxvpc.id
    depends_on = [aws_vpc.clixxvpc]
}

##Create Listener Resource
resource "aws_lb_listener" "front_end" {
    load_balancer_arn = aws_lb.test.arn
    port              = "80"
    protocol          = "HTTP"
    
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.clixxvpc.arn
    }
}






