#!/usr/bin/env bash

function Check_linux_system(){
    linux_version=`cat /etc/redhat-release`
    if [[ ${linux_version} =~ "CentOS" ]];then
        echo -e "\033[32;32m 系统为 ${linux_version} \033[0m \n"
    else
        echo -e "\033[32;32m 系统不是CentOS,该脚本只支持CentOS环境\033[0m \n"
        exit 1
    fi
}

function Set_hostname(){
    if [ -n "$HostName" ];then
      grep $HostName /etc/hostname && echo -e "\033[32;32m 主机名已设置，退出设置主机名步骤 \033[0m \n" && return
      case $HostName in
      help)
        echo -e "\033[32;32m bash init.sh 主机名 \033[0m \n"
        exit 1
      ;;
      *)
        hostname $HostName
        echo "$HostName" > /etc/hostname
        echo "127.0.0.1 $HostName" >> /etc/hosts
      ;;
      esac
    else
      echo -e "\033[32;32m 输入为空，请参照 bash init.sh 主机名 \033[0m \n"
      exit 1
    fi
}

function Install_depend_environment(){
    rpm -qa | grep nfs-utils &> /dev/null && echo -e "\033[32;32m 已完成依赖环境安装，退出依赖环境安装步骤 \033[0m \n" && return
    yum install -y nfs-utils curl yum-utils device-mapper-persistent-data lvm2 net-tools conntrack-tools wget vim  ntpdate libseccomp libtool-ltdl telnet
    echo -e "\033[32;32m 升级Centos7系统内核到5版本，解决Docker-ce版本兼容问题\033[0m \n"
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org && \
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm && \
    yum --disablerepo=\* --enablerepo=elrepo-kernel repolist && \
    yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-ml.x86_64 && \
    yum remove -y kernel-tools-libs.x86_64 kernel-tools.x86_64 && \
    yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-ml-tools.x86_64 && \
    grub2-set-default 0
    modprobe br_netfilter
    cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
    sysctl -p /etc/sysctl.d/k8s.conf
    ls /proc/sys/net/bridge
}

function Install_docker(){
    rpm -qa | grep docker && echo -e "\033[32;32m 已安装docker，退出安装docker步骤 \033[0m \n" && return
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum makecache fast
    yum -y install docker-ce
    systemctl enable docker.service
    systemctl start docker.service
    systemctl stop docker.service
    echo '{"registry-mirrors": ["https://4xr1qpsp.mirror.aliyuncs.com"]}' > /etc/docker/daemon.json
    systemctl daemon-reload
    systemctl start docker
}


# 初始化顺序
#关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

#关闭交换内存
echo "vm.swappiness = 0">> /etc/sysctl.conf
swapoff -a && swapon -a && swapoff -a
sysctl -p
#设置主机名称
HostName=`hostnamectl status | grep hostname | awk '{print $3}'`
if [[  $hostname == "k8s-node"* ]];then
HostName=?HOSTNAME
fi
Check_linux_system && \
Set_hostname && \
Install_depend_environment && \
Install_docker
#重启docker
systemctl restart docker

#安装kubeadm
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
EOF

yum makecache fast
yum -y remove kubelet kubeadm kubectl
#为空使用默认版本
version=`yum list kubelet kubeadm kubectl | grep kubeadm | awk '{print $2}'`

yum install -y kubeadm-$version kubectl-$version kubelet-$version --disableexclu
des=kubernetes && systemctl enable --now kubelet

?JOIN_COMMAND

