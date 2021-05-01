#!/bin/bash
# EBS configuration script

# update system
sudo yum update -y

#Variable Declaration
ebs_vol="/dev/sdb /dev/sdc /dev/sdd"
log_vol="/dev/stack_vg/Lv_u01 /dev/stack_vg/Lv_u02 /dev/stack_vg/Lv_u03"
log_dir="/u01 /u02 /u03"

# create a partition for attached EBS volumes
# fdisk /dev/xvd”n”  note "n" represent the device mapping of your disk


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

disk_partition="/dev/sdb1 /dev/sdc1 /dev/sdd1"

#CREATING VOLUME GROUP
for lv in ${disk_partition}
do
sudo pvcreate $lv
done

##CREATING VOLUME GROUP
for vg in $disk_partition
do
sudo vgcreate $vg
done

# Create logical volumes allocating about 5G
sudo lvcreate -L 5G -n Lv_u01 stack_vg
sudo lvcreate -L 5G -n Lv_u02 stack_vg
sudo lvcreate -L 5G -n Lv_u03 stack_vg

# Create ext4 filesystems on these logical volumes
for ef in ${log_vol}
do
sudo mkfs.ext4 $ef
done

# Create new directory for logical volumes
for nd in ${log_dir}
do
sudo mkdir $nd
done

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



