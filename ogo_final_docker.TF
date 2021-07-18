resource "aws_instance" "web" {
    ami           = var.AMIS["us-east-1"]
    instance_type = "t2.micro"
    user_data = "${file("docker_bootstrap.sh")}"
    security_groups = [ "tf-security141" ]
    key_name = var.PATH_TO_PRIVATE_KEY
    iam_instance_profile = "S3-Admin-Role"
    
    tags = {
    Name = "TF--Flaskapp"
    }
}

