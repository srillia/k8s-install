hostname=`hostnamectl status | grep hostname | awk '{print $3}'`
if [[  $hostname == "k8s-node"* ]];then
	if [ ! -f "count.txt" ]; then
        	echo 1 > count.txt
	fi
	num=`cat count.txt`
	echo $((num + 1)) > count.txt
	hostname="k8s-node"$num
fi
echo $hostname
