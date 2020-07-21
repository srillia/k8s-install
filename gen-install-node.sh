join_token=`kubeadm token create --print-join-command`
if [ ! -f "count.txt" ]; then
        echo 1 > count.txt
fi
num=`cat count.txt`
echo $((num + 1)) > count.txt
hostname="k8s-node"$num

\cp install-node-template.tpl install-node#genrated.sh
chmod +x install-node-template.sh
sed -i "s#?HOSTNAME#${hostname}#g"  install-node#genrated.sh
join_token=`kubeadm token create --print-join-command`
sed -i "s#?JOIN_TOKEN#${join_token}#g"  install-node#genrated.sh
