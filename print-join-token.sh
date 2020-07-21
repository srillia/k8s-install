kubeadm token create --print-join-command  
if [ ! -f "count.txt" ]; then
        echo 1 > count.txt
fi
num=`cat count.txt`
echo $((num + 1)) > count.txt
hostname="k8s-node"$num
