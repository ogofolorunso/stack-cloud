resource "aws_instance" "web" {
    ami           = var.AMIS["us-east-1"]
    instance_type = "t2.micro"
    user_data = templatefile("TF-EFSbootstap.sh", {
        MOUNT_POINT="/var/www/html",
        REGION = var.AWS_REGION,
        FILE_SYSTEM_ID = aws_efs_file_system.ogo.id,
        DB_NAME = var.DATABASE_NAME,
        DB_USER = var.DB_USERNAME,
        RDS_ENDPOINT = var.AWS_RDS_ENDPOINT,
        RDS_PASSWORD = var.AWS_RDS_PASSWORD

        })
    security_groups = [ "tf-security141" ]
    depends_on = [aws_efs_mount_target.alpha]
    key_name = var.PATH_TO_PRIVATE_KEY
    iam_instance_profile = "S3-Admin-Role"


    tags = {
    Name = "TF--EC2"
    }
}