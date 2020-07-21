./uninstall.sh
./prepare-1.sh k8s-master
./k8sadm-2.sh
./pull-imgs-3.sh v1.18.3
./init-master-4.sh 192.168.10.234 v1.18.3
./config-network-5.sh
