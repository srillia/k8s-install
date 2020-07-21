./prepare-1.sh k8s-master
./k8sadm-2.sh v1.18.6
./pull-imgs-3.sh v1.18.3
./init-master-4.sh 192.168.10.234 v1.18.3
./flanneld.sh v0.12.0-amd64
./config-network-5.sh
