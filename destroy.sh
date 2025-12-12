#!/bin/bash
set -e  # exit immediately if any command fails

# List of module folders in descending order
modules=(
  "08-web-alb"
  "07-acm"
  "06-catalogue"
  "05-app-alb"
  "04-databases"
  "03-VPN"
  "02-bastion"
  "01-SG"
  "00-VPC"
)

for module in "${modules[@]}"; do
  echo "🔥 Destroying $module ..."
  cd "$module"
  
  terraform init -upgrade
  terraform destroy -auto-approve
  
  cd ..
  echo "✅ Finished destroying $module"
done

echo "💥 All modules destroyed successfully!"

