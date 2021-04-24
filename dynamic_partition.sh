#!/bin/bash

ebs_disk=("/dev/xvdb" "/dev/xvdc" "/dev/xvdd" "/dev/xvde")

for disk in $ebs_disk;
do
        sudo fdisk $ebs_disk <<EOT
        n
        p
        1


        w

EOT
done

ls -ltr /dev/sd*

disk_partition=("/dev/sdb1" "/dev/sdc1" "/dev/sdd1" "/dev/sde1")



#CREATING VOLUME GROUP

for lv in $disk_partition;
do
        sudo pvcreate  $disk_partition
done

##CREATING VOLUME GROUP

for vg in $disk_partition;
do
        sudo vgcreate  $disk_partition
done
~

