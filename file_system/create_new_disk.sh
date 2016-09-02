#!/bin/bash

# See more details here: http://www.techotopia.com/index.php/Adding_a_New_Disk_Drive_to_a_CentOS_6_System

# see what are the disks available
ls /dev/sd*
# the above will show something like: "/dev/sda  /dev/sda1  /dev/sda2"

# format new file system and do other steps according to the link above
# TODO