#!/bin/bash
sudo apt update -y
sudo apt install -y fontconfig openjdk-17-jdk  # Install Java 17

# Add Jenkins repository and key
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install -y jenkins  # Install Jenkins
sudo systemctl start jenkins  # Start Jenkins service
sudo systemctl enable jenkins  # Enable Jenkins on startup

# Format and mount extra disk
sudo mkfs.ext4 /dev/xvdb  # Format disk with ext4
sudo mkdir -p /mnt/extradisk  # Create mount point
sudo mount /dev/xvdb /mnt/extradisk  # Mount disk
echo '/dev/xvdb /mnt/extradisk ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab  # Persist mount
