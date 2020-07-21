if [ ! -f "count.txt" ]; then 
	echo 1 > count.txt
fi
num=`cat count.txt`
echo `num + 1` > count.txt
./prepare-1.sh k8s-node$num
./k8sadm-2.sh v1.18.6
