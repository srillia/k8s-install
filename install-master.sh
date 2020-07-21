source config
./uninstall.sh
./prepare-1.sh $MASTER_HOST
./k8sadm-2.sh
./pull-imgs-3.sh $K8S_VERSION
./init-master-4.sh $MASTER_IP $K8S_VERSION
./config-network-5.sh
