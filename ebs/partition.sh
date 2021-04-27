#!/bin/bash
# EBS configuration script
# display log
exec > >(tee /var/log/test.log|logger -t test -s 2>/dev/console) 2>&1


# update system
sudo yum update -y

# create a partition for attached EBS volumes
# fdisk /dev/xvd”n”  note "n" represent the device mapping of your disk
ebs_vol="/dev/sdb /dev/sdc /dev/sdd"


for var in ${ebs_vol}
do 
sudo fdisk $var <<EOT
n
P
1
2048
16777215
w
EOT
done

# Create disks labels (create physical volumes)
sudo pvcreate /dev/sdb1 /dev/sdc1 /dev/sdd1

# Create a volume group ( named stack_vg)
sudo vgcreate stack_vg /dev/sdb1 /dev/sdc1 /dev/sdd1

# Create logical volumes allocating about 5G
sudo lvcreate -L 5G -n Lv_u01 stack_vg
sudo lvcreate -L 5G -n Lv_u02 stack_vg
sudo lvcreate -L 5G -n Lv_u03 stack_vg


# Create ext4 filesystems on these logical volumes
sudo mkfs.ext4 /dev/stack_vg/Lv_u01
sudo mkfs.ext4 /dev/stack_vg/Lv_u02
sudo mkfs.ext4 /dev/stack_vg/Lv_u03

# Create new directory for logical volumes
sudo mkdir /u01
sudo mkdir /u02
sudo mkdir /u03

# Mount logical volumes to newly created directories
sudo mount /dev/stack_vg/Lv_u01 /u01
sudo mount /dev/stack_vg/Lv_u02 /u02
sudo mount /dev/stack_vg/Lv_u03 /u03

# edit fstab
sudo su
disk_b=`blkid | grep 'u01' | awk '{print $2}'`
disk_c=`blkid | grep 'u02' | awk '{print $2}'`
disk_d=`blkid | grep 'u03' | awk '{print $2}'`
sudo echo $disk_b /u01 ext4 defaults 1 2 >> /etc/fstab
sudo echo $disk_c /u02 ext4 defaults 1 2 >> /etc/fstab
sudo echo $disk_d /u03 ext4 defaults 1 2 >> /etc/fstab



