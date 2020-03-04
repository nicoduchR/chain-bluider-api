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
apt-get install supervisor
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
geth account new --datadir datadir

echo "Please type your password again. It will save it to /root/datadir/password.txt in order to facilitate the script execution:"
read password
echo $password >> /root/datadir/password.txt

# Transforming address string
address=$(cat /root/datadir/keystore/$file | grep -Po '"address":\K"[A-Za-z0-9/._]*"')
address="${address:0:1}0x${address:1}"
address=${address:1:-1}
# Save it to text file 
echo $address >> /root/datadir/address.txt


echo "Genesis initialization"
geth --datadir ./datadir init ./genesis.json

echo "Please enter the IP address of the bootnode (127.0.0.1 if on it's on the same machine):"
read ip
enode="enode://$(bootnode --nodekeyhex $(cat boot.key) -writeaddress)@$ip:0?discport=30310"

for file in /root/datadir/keystore/*; do
  file="${file##*/}"
done



touch /etc/supervisor/conf.d/node.conf
echo "[program:node]
command=geth --datadir /root/datadir/ --syncmode 'full' --port 30311 --rpc --rpcaddr '0.0.0.0' --rpcport 8501 --rpcapi 'personal,db,eth,net,web3,txpool,miner,admin,clique' --bootnodes '$enode' --networkid 1100 -unlock '$address' --password /root/datadir/password.txt --mine --allow-insecure-unlock
autostart=true
autorestart=true
stderr_logfile=/root/nodeerr.log
stdout_logfile=/root/nodelog.log" >> /etc/supervisor/conf.d/node.conf

supervisorctl reread
supervisorctl update


echo "Everything goes fine. You blockchain is running"