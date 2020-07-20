#!/bin/bash

set -e
k8s_version=$1
if test -z $k8s_version; then
	k8s_version=v1.18.3
fi
versions=`kubeadm config images list --kubernetes-version $k8s_version`
#versions=`kubeadm config images list`
apiserver_version_tmp=`echo $versions | sed 's/ /\n/g'| grep k8s.gcr.io/kube-apiserver`
pause_version_tmp=`echo $versions | sed 's/ /\n/g'| grep k8s.gcr.io/pause`
etcd_version_tmp=`echo $versions | sed 's/ /\n/g'| grep k8s.gcr.io/etcd`
coredns_version_tmp=`echo $versions | sed 's/ /\n/g'| grep k8s.gcr.io/coredns`
apiserver_version=${apiserver_version_tmp#*:}
pause_version=${pause_version_tmp#*:}
etcd_version=${etcd_version_tmp#*:}
coredns_version=${coredns_version_tmp#*:}
echo $apiserver_version
echo $pause_version
echo $etcd_version
echo $coredns_version

#KUBE_VERSION=v1.16.3
#KUBE_PAUSE_VERSION=3.1
#ETCD_VERSION=3.3.15-0
#CORE_DNS_VERSION=1.6.2

KUBE_VERSION=$apiserver_version
KUBE_PAUSE_VERSION=$pause_version
ETCD_VERSION=$etcd_version
CORE_DNS_VERSION=$coredns_version

GCR_URL=k8s.gcr.io
ALIYUN_URL=registry.cn-hangzhou.aliyuncs.com/google_containers

images=(kube-proxy:${KUBE_VERSION}
kube-scheduler:${KUBE_VERSION}
kube-controller-manager:${KUBE_VERSION}
kube-apiserver:${KUBE_VERSION}
pause:${KUBE_PAUSE_VERSION}
etcd:${ETCD_VERSION}
coredns:${CORE_DNS_VERSION})

for imageName in ${images[@]} ; do
  docker pull $ALIYUN_URL/$imageName
  docker tag  $ALIYUN_URL/$imageName $GCR_URL/$imageName
  docker rmi $ALIYUN_URL/$imageName
done

