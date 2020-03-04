#!/bin/bash
# Usage: Join an already existing blockchain network
# Author: Nicolas Duchemann
# -------------------------------------------------
echo "Usage: Join an already existing blockchain network"


echo "Creation of node"
geth account import --datadir ./datadir2 ./key2.txt

echo "Please type your password again. It will save it to /root/datadir2/password.txt in order to facilitate the script execution:"
read password
echo $password >> /root/datadir2/password.txt

echo "Genesis initialization"
geth --datadir ./datadir2 init ./genesis.json

echo "Please enter the IP address of the bootnode (127.0.0.1 if on it's on the same machine):"
read ip
enode="enode://$(bootnode --nodekeyhex $(cat boot.key) -writeaddress)@$ip:0?discport=30310"

for file in /root/datadir2/keystore/*; do
  file="${file##*/}"
done

#Transforming address string
address=$(cat /root/datadir2/keystore/$file | grep -Po '"address":\K"[A-Za-z0-9/._]*"')
address="${address:0:1}0x${address:1}"
address=${address:1:-1}


touch /etc/supervisor/conf.d/node2.conf
echo "[program:node]
command=geth --datadir /root/datadir2/ --syncmode 'full' --port 30311 --rpc --rpcaddr '0.0.0.0' --rpcport 8501 --rpcapi 'personal,db,eth,net,web3,txpool,miner,admin,clique' --bootnodes '$enode' --networkid 1100 -unlock '$address' --password /root/datadir2/password.txt --mine --allow-insecure-unlock
autostart=true
autorestart=true
stderr_logfile=/root/nodeerr2.log
stdout_logfile=/root/nodelog2.log" >> /etc/supervisor/conf.d/node2.conf

supervisorctl reread
supervisorctl update


echo "Everything goes fine. New peer joined the blockchain!"