##########################################################
# Filename: master_setup.sh
# Description: Kubernetes Master Node Initialization
##########################################################

#!/bin/bash
set -e

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "[ERROR] Please run this script as root or use: sudo ./master_setup.sh"
  exit 1
fi

echo "[INFO] Initializing Kubernetes Master..."
kubeadm config images pull
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU --ignore-preflight-errors=Mem

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml

echo "[INFO] Master node initialized. Run the following on worker nodes:"
kubeadm token create --print-join-command

kubectl get nodes -o wide
kubectl get pods --all-namespaces

#run this to setup kubectl
# run below aprt the script
# sudo mkdir -p /home/ubuntu/.kube
# sudo cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
# sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config