
#!/bin/bash

sudo su -

#Partioning the 3 different EBS volumes
#fdisk /dev/xvdc < fdisk_cmds
#(echo n; echo p; echo 1; echo 2048; echo 16777215; echo w) | fdisk /dev/xvdb

sudo fdisk /dev/xvdb <<EOT
n
p
1
2048
16777215
w
EOT
sudo fdisk /dev/xvdc <<EOT
n
p
1
2048
16777215
w
EOT
sudo fdisk /dev/xvdd <<EOT
n
p
1
2048
16777215
w
EOT
sudo fdisk /dev/xvde <<EOT
n
p
1
2048
16777215
w
EOT

#Confirming all partitons have been created
ls -ltr /dev/sd*

#CREATING VOLUME GROUP AND LOGICAL VOLUMES
sudo pvcreate  /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1
sudo vgcreate stack_vg /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1

#Create the Logical Volumes (LUNS) with about 5G of space allocated initially
sudo lvcreate -L 5G -n Lv_u01 stack_vg
sudo lvcreate -L 5G -n Lv_u02 stack_vg
sudo lvcreate -L 5G -n Lv_u03 stack_vg
sudo lvcreate -L 5G -n Lv_u04 stack_vg

#To confirm newly created volume
lvs

#Creating ext4  filesystems on these logical volumes
sudo mkfs.ext4 /dev/stack_vg/Lv_u01
sudo mkfs.ext4 /dev/stack_vg/Lv_u02
sudo mkfs.ext4 /dev/stack_vg/Lv_u03
sudo mkfs.ext4 /dev/stack_vg/Lv_u04

#Create new directories Mount newly created disks
sudo mkdir /u01
sudo mkdir /u02
sudo mkdir /u03
sudo mkdir /u04
sudo mount /dev/stack_vg/Lv_u01 /u01
sudo mount /dev/stack_vg/Lv_u02 /u02
sudo mount /dev/stack_vg/Lv_u03 /u03
sudo mount /dev/stack_vg/Lv_u04 /u04

#Confirming mounti is completed
df -h

#Resizing the disks(Extending the disk by 3G)
#resize2fs /dev/mapper/stack_vg-Lv_u01