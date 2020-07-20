#!/bin/bash
version=$1
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
EOF

yum makecache fast
yum -y remove kubelet kubeadm kubectl
if test -z $version; then
#为空使用默认版本
version=`yum list kubelet kubeadm kubectl | grep kubeadm | awk '{print $2}'`
fi
yum install -y kubeadm-$version kubectl-$version kubelet-$version --disableexcludes=kubernetes && systemctl enable --now kubelet
