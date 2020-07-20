kubeadm init \
 --apiserver-advertise-address $1 \
 --kubernetes-version=$2 \
 --pod-network-cidr=10.244.0.0/16

