./prepare-1.sh k8s-master
./k8sadm-2.sh v.1.18.3
./pull-imgs-3.sh v.1.18.3
./init-master.sh 192.168.10.234 v.1.18.3
