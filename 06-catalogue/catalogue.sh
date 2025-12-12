#!/bin/bash

component=$1
environment=$2
dnf install ansible -y
ansible-pull -U https://github.com/viho-kernel/ansible-roboshop-roles-tf.git -e component=$1 -e env=$2 main.yaml