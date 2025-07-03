##touch common_setup.sh && chmod 777 common_setup.sh

#!/bin/bash
# Filename: common_setup.sh
# Description: Common Kubernetes setup for all nodes (master + workers)

set -e

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "[ERROR] Please run this script as root or use: sudo ./common.sh"
  exit 1
fi

echo "[INFO] Starting common Kubernetes setup..."

apt update -y

# Hostname must be set manually per node
# e.g., hostnamectl set-hostname kmaster-node / worker-node1

# Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install Docker (optional)
apt install -y docker.io

# Load kernel modules
modprobe overlay
modprobe br_netfilter

tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# Set sysctl params
tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# Install containerd
apt install -y curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt update -y
apt install -y containerd.io

# Configure containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

# Install Kubernetes packages
apt-get install -y apt-transport-https ca-certificates curl gpg
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | \
  gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | \
  tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
systemctl enable kubelet

echo "[INFO] Common setup complete. Reboot system if needed."
####sudo ./common_setup.sh