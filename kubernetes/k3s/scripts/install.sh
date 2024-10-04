#!/bin/bash

# Exit on error
set -euxo pipefail

NODENAME=$(hostname -s)

# Install k3s
# curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san ${LOCAL_IP}  --flannel-backend=none --disable-network-policy --disable=traefik" sh -
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="\
--node-name=$NODENAME \
--advertise-address=$CONTROL_IP \
--flannel-backend=none \
--disable-network-policy \
--disable=traefik \
--cluster-cidr=$POD_CIDR \
--service-cidr=$SERVICE_CIDR \
--tls-san=$CONTROL_IP" sh -

# Wait for k3s to be ready
while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
  sleep 1
done

mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
sudo chmod 600 /home/vagrant/.kube/config


# Install Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/calico.yaml

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -f get_helm.sh

# Install k9s for vagrant user 
# curl -sS https://webinstall.dev/k9s | bash

# Active bash completion
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc
echo "source <(kubectl completion bash)" >> /home/vagrant/.bashrc
echo "source <(helm completion bash)" >> /home/vagrant/.bashrc

# Alias
echo "alias ks=k9s" >> /home/vagrant/.bashrc
echo "alias k=kubectl" >> /home/vagrant/.bashrc
echo "complete -F __start_kubectl k" >> /home/vagrant/.bashrc


# Copy kubeconfig to shared folder
config_path="/vagrant/configs"

if [ -d $config_path ]; then
  rm -f $config_path/*
else
  mkdir -p $config_path
fi

cp /etc/rancher/k3s/k3s.yaml /vagrant/configs/config
IP=$(hostname -I | awk '{print $2}')
sed -i "s|https://127.0.0.1:6443|https://${IP}:6443|g" /vagrant/configs/config
