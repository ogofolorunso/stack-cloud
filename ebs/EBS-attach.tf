#CREATE EC2 INSTANCE
#Attach bootstrap script to partition files
resource "aws_instance" "EBSvol" {
    ami           = var.AMIS["us-east-1"]
    instance_type = "t2.micro"
    user_data = file("ebs/partition.sh")
    security_groups = [ "tf-security14" ]
    key_name = var.PATH_TO_PRIVATE_KEY
    iam_instance_profile = "S3-Admin-Role"
    availability_zone = "us-east-1a"

    tags = {
    Name = "EBSvol--EC2"
    }
}



##CREATE EBS VOLUME
## ATTACH 4 EBS VOLUMEs
resource "aws_ebs_volume" "TF" {
    availability_zone = "us-east-1a"
    size              = 8
}

resource "aws_volume_attachment" "ebs_att" {
    device_name = "/dev/sdb"
    volume_id   = aws_ebs_volume.TF.id
    instance_id = aws_instance.EBSvol.id
    force_detach = true
}

resource "aws_ebs_volume" "TF2" {
    availability_zone = "us-east-1a"
    size              = 8
}

resource "aws_volume_attachment" "ebs_att2" {
    device_name = "/dev/sdc"
    volume_id   = aws_ebs_volume.TF2.id
    instance_id = aws_instance.EBSvol.id
    force_detach = true
}

resource "aws_ebs_volume" "TF3" {
    availability_zone = "us-east-1a"
    size              = 8
}

resource "aws_volume_attachment" "ebs_att3" {
    device_name = "/dev/sdd"
    volume_id   = aws_ebs_volume.TF3.id
    instance_id = aws_instance.EBSvol.id
    force_detach = true
}
