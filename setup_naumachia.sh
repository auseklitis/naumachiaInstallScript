#!/bin/bash

# Update and install prerequisites
sudo apt-get update &&
sudo apt-get install -y ca-certificates curl git python3 python3-pip openvpn

# Setup Docker's APT repository
sudo install -m 0755 -d /etc/apt/keyrings &&
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc &&
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to APT sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker and related packages
sudo apt-get update &&
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

# Clone Naumachia repository and install dependencies
git clone https://github.com/nategraf/Naumachia &&
cd Naumachia &&
pip3 install -r requirements.txt --break-system-packages &&
cd ..

# Install and configure l2bridge driver
sudo curl -L https://raw.githubusercontent.com/nategraf/l2bridge-driver/master/sysv.sh -o /etc/init.d/l2bridge &&
sudo chmod +x /etc/init.d/l2bridge &&
sudo curl -L https://github.com/nategraf/l2bridge-driver/releases/latest/download/l2bridge-driver.linux.amd64 -o /usr/local/bin/l2bridge &&
sudo chmod +x /usr/local/bin/l2bridge &&
sudo update-rc.d l2bridge defaults &&
sudo service l2bridge start

# Check if l2bridge driver is running
sudo stat /run/docker/plugins/l2bridge.sock

# Install and configure static-ipam driver
sudo curl -L https://raw.githubusercontent.com/nategraf/static-ipam-driver/master/sysv.sh -o /etc/init.d/static-ipam &&
sudo chmod +x /etc/init.d/static-ipam &&
sudo curl -L https://github.com/nategraf/static-ipam-driver/releases/latest/download/static-ipam-driver.linux.amd64 -o /usr/local/bin/static-ipam &&
sudo chmod +x /usr/local/bin/static-ipam &&
sudo update-rc.d static-ipam defaults &&
sudo service static-ipam start

# Check if static-ipam driver is running
sudo stat /run/docker/plugins/static.sock

# Additional configurations
cd Naumachia

# Modify Dockerfiles to include --break-system-packages flag
sed -i 's/pip install -r \/requirements.txt/pip install -r \/requirements.txt --break-system-packages/g' manager/build/Dockerfile
sed -i 's/pip install -r requirements.txt/pip install -r requirements.txt --break-system-packages/g' openvpn/build/Dockerfile
sed -i 's/pip install -r \/app\/requirements.txt/pip install -r \/app\/requirements.txt --break-system-packages/g' test/loader/Dockerfile
sed -i 's/pip3 install -r \/app\/requirements.txt/pip3 install -r \/app\/requirements.txt --break-system-packages/g' test/worker/Dockerfile
sed -i 's/pip install -r \.\/requirements.txt/pip install -r \.\/requirements.txt --break-system-packages/g' registrar/Dockerfile

# Clone Naumachia challenges and set up environment
git clone https://github.com/nategraf/Naumachia-challenges.git challenges
cp challenges/config.yml ./

# Install Python dependencies for OpenVPN
pip3 install -r openvpn/build/requirements.txt --break-system-packages

# Run configuration script and build challenges
sed -i '/files:/i\        commonname: wordpress.lan' config.yml
python3 configure.py
sudo ./disable-bridge-nf-iptables.sh
sudo rm -rf challenges/middle-arpon
./build-challenges.sh
#sudo docker compose up

# Install missing dependencies and retry
#sudo pip3 install -r openvpn/build/requirements.txt --break-system-packages
#sudo pip3 install -r requirements.txt --break-system-packages
#pip3 install -r manager/build/requirements.txt --break-system-packages
