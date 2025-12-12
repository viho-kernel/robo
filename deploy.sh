#!/bin/bash
set -e  # exit immediately if any command fails

# Pre-VPN modules
modules_pre_vpn=(
  "00-VPC"
  "01-SG"
  "02-bastion"
  "03-VPN"
)

# Post-VPN modules
modules_post_vpn=(
  "04-databases"
  "05-app-alb"
  "06-catalogue"
  "07-acm"
  "08-web-alb"
  "09-web"
  "10-cdn"
  "11-user"
  "12-shipping"
  "13-cart"
  "14-Payment"
)

# Step 1: Deploy pre-VPN modules
for module in "${modules_pre_vpn[@]}"; do
  echo "🚀 Deploying $module ..."
  cd "$module"
  terraform init -upgrade
  terraform apply -auto-approve
  cd ..
  echo "✅ Finished $module"
done

# Step 2: Fetch VPN public IP from Terraform output
vpn_ip=$(terraform -chdir=03-VPN output -raw vpn_public_ip)
echo "📡 Expected VPN IP: $vpn_ip"

# Step 3: Wait until system IP matches VPN IP
echo "⏳ Waiting for VPN connection..."
while true; do
  current_ip=$(curl -s ifconfig.me)
  echo "Current system IP: $current_ip"
  if [ "$current_ip" == "$vpn_ip" ]; then
    echo "✅ VPN connection detected (IP matched $vpn_ip)"
    break
  fi
  sleep 10
done

# Step 4: Deploy post-VPN modules
for module in "${modules_post_vpn[@]}"; do
  echo "🚀 Deploying $module ..."
  cd "$module"
  terraform init -upgrade
  terraform apply -auto-approve
  cd ..
  echo "✅ Finished $module"
done

echo "🎉 All modules deployed successfully!"

