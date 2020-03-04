#!/bin/bash
# Usage: Create blockchain network and join with the first node
# Author: Nicolas Duchemann
# -------------------------------------------------
echo "Usage: Create blockchain network"
echo "Installing geth ..."
apt-get install software-properties-common \
&& add-apt-repository -y ppa:ethereum/ethereum \
&& apt-get update \
&& apt-get -y install ethereum



echo "Creation of bootnode"
cd  /root/
bootnode -genkey boot.key
apt-get -y install supervisor
touch /etc/supervisor/conf.d/boot.conf
echo "[program:bootnode]
command=bootnode -nodekey /root/boot.key -verbosity 9 -addr :30310
autostart=true
autorestart=true
stderr_logfile=/root/booterr.log
stdout_logfile=/root/bootlog.log" >> /etc/supervisor/conf.d/boot.conf

supervisorctl reread
supervisorctl update

echo "Creation of node"


echo -n "Enter your node number: "
read NODE_NUMBER

echo -n "Your node number is $NODE_NUMBER. Generating private key ....... "

case $NODE_NUMBER in

  1)
    echo ac934d5957cf99bdf11944cbcc22b004844ab8a780709882dcff181a76eb8b4a >> ./key1.txt
    ;;

  2)
    echo 3c4f61b1e9631723e2df89ccbee6f7c94ca7049995c16bdb342e3d5bda5790ef >> ./key2.txt
    ;;

  3)
    echo a472c90cc7e3b4b2f83d418e7febbe32493ae86d1053cc8e03c5f5e81a38bb0e >> ./key3.txt
    ;;

  4)
    echo d0706c2f2e4f64d6f5b684ee428a328dbd0cb2c82118388d2f16b6782c3dfcdd >> ./key4.txt
    ;;

  5)
    echo 68bb3f926ca7503f95fff5e3203ba42b0966e5838e8415589f72b5dc2e705d5f >> ./key5.txt
    ;;

  6)
    echo fc548cfa02f001cccbbbaee60a6c4167e0661225b5c3862a9755ceb788222bc7 >> ./key6.txt
    ;;

  FIRE)
    echo ac934d5957cf99bdf11944cbcc22b004844ab8a780709882dcff181a76eb8b4a >> ./key2.txt
    echo 3c4f61b1e9631723e2df89ccbee6f7c94ca7049995c16bdb342e3d5bda5790ef >> ./key2.txt
    echo a472c90cc7e3b4b2f83d418e7febbe32493ae86d1053cc8e03c5f5e81a38bb0e >> ./key3.txt
    echo d0706c2f2e4f64d6f5b684ee428a328dbd0cb2c82118388d2f16b6782c3dfcdd >> ./key4.txt
    echo 68bb3f926ca7503f95fff5e3203ba42b0966e5838e8415589f72b5dc2e705d5f >> ./key5.txt
    echo fc548cfa02f001cccbbbaee60a6c4167e0661225b5c3862a9755ceb788222bc7 >> ./key6.txt
    ;;

esac


echo "Please type your password. It will save it to /root/password.txt in order to facilitate the script execution:"
read password
touch ./password.txt
echo $password >> ./password.txt




case $NODE_NUMBER in

  1)
    geth account import --datadir ./datadir --password ./password.txt ./key1.txt
    ;;

  2)
    geth account import --datadir ./datadir --password ./password.txt ./key2.txt
    ;;

  3)
    geth account import --datadir ./datadir --password ./password.txt ./key3.txt
    ;;

  4)
    geth account import --datadir ./datadir --password ./password.txt ./key4.txt
    ;;

  5)
    geth account import --datadir ./datadir --password ./password.txt ./key5.txt
    ;;

  6)
    geth account import --datadir ./datadir --password ./password.txt ./key6.txt
    ;;

  FIRE)
    geth account import --datadir ./datadir --password ./password.txt ./key6.txt
    ;;

esac


for file in ./datadir/keystore/*; do
  file="${file##*/}"
done

# Transforming address string
address=$(cat ./datadir/keystore/$file | grep -Po '"address":\K"[A-Za-z0-9/._]*"')
address="${address:0:1}0x${address:1}"
address=${address:1:-1}
# Save it to text file 
echo $address >> ./datadir/address.txt


echo "Genesis initialization"
geth --datadir ./datadir init ./genesis.json

echo "Please enter the IP address of the bootnode (127.0.0.1 if on it's on the same machine). YOU MUST HAVE THE BOOT.KEY FILE STORED AT /root.boot.key"
read ip
enode="enode://$(bootnode --nodekeyhex $(cat ./boot.key) -writeaddress)@127.0.0.1:0?discport=30310"

touch /etc/supervisor/conf.d/node.conf
echo "[program:node]
command=geth --datadir /root/datadir/ --syncmode 'full' --port 30311 --rpc --rpcaddr '0.0.0.0' --rpcport 8501 --rpcapi 'personal,db,eth,net,web3,txpool,miner,admin,clique' --bootnodes '$enode' --networkid 974 -unlock '$address' --password /root/password.txt --mine --allow-insecure-unlock
autostart=true
autorestart=true
stderr_logfile=/root/nodeerr.log
stdout_logfile=/root/nodelog.log" >> /etc/supervisor/conf.d/node.conf


supervisorctl reread
supervisorctl update

echo "Everything goes fine. You blockchain is running. Peers can now join"