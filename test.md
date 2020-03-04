[program:node_client]
command=geth --datadir /root/datadir/ --syncmode 'full' --port 30311 --rpc --rpcaddr '0.0.0.0' --rpcport 8501 --rpcapi 'personal,db,eth,net,web3,txpool,miner,admin,clique' --bootnodes 'enode://131a21cdd40ed2be244f5c5e85a66980b0a768640f4b24836e911deb8fa85cb03e91c46393fb08f899e57a168c0cede82f57043d9a0c037eea8f02f1f91db665@127.0.0.1:0?discport=30310' --networkid 1100 -unlock '0xc51d07cd9cd1c235ee710f6b4253615d324e759e' --password /root/datadir/password.txt --mine --allow-insecure-unlock
autostart=true
autorestart=true
stderr_logfile=/root/nodeerr.log
stdout_logfile=/root/nodelog.log




[program:node_client]
command=geth --datadir /root/datadir/ --syncmode 'full' --port 30311 --rpc --rpcaddr '0.0.0.0' --rpcport 8501 --rpcapi 'personal,db,eth,net,web3,txpool,miner,admin,clique' --bootnodes 'enode://131a21cdd40ed2be244f5c5e85a66980b0a768640f4b24836e911deb8fa85cb03e91c46393fb08f899e57a168c0cede82f57043d9a0c037eea8f02f1f91db665@192.168.64.6:0?discport=30310' --networkid 1100 -unlock '0x95ef74d65f0486a62205dbb0f61f67909a69c1c9' --password /root/datadir/password.txt --mine --allow-insecure-unlock
autostart=true
autorestart=true
stderr_logfile=/root/nodeerr.log
stdout_logfile=/root/nodelog.log




enode://131a21cdd40ed2be244f5c5e85a66980b0a768640f4b24836e911deb8fa85cb03e91c46393fb08f899e57a168c0cede82f57043d9a0c037eea8f02f1f91db665@192.168.64.6?discport=30310