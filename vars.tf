variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}

variable "RDS_PASSWORD" {}

variable "AWS_REGION" {
  default = "us-east-1"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "MyFirstEC2"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey.pub"
}

variable "AMIS" {
  type = map(string)
  default = {
   # us-east-1 = "ami-13be557e"
    us-east-1 = "ami-0742b4e673072066f"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
}

variable "my_aws_subnet" {
  type = map(string)
  default = {
    "us-east-1a" = "subnet-5f447412"
    "us-east-1b" = "subnet-e2016cbd"
    "us-east-1c" = "subnet-e5d2b383"  
    "us-east-1d" = "subnet-fcafc0dd"
    "us-east-1e" = "subnet-5d93276c"
  }
}  

variable "AWS_RDS_ENDPOINT" {
  default = "database-1.c1b7pnxpluqx.us-east-1.rds.amazonaws.com"
}

variable "DATABASE_NAME" {
  default = "stack-wordpress-db3"
}

variable "DB_USERNAME" {
  default = "wordpressuser"
}

variable "DB_PASSWORD" {
}


