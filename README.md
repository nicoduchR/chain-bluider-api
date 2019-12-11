# chain-bluider-api


# Launch

``` 
$ npm install
$ npm start
```
# What do we need in the script

## Step 0 - Install Zerotier
```shell
curl -s https://install.zerotier.com | sudo bash
```

We'll need this tool to setup a VPN in order to make our differents nodes interact with each others. This is useful if you don't have public IP address for your machine. If you have, we don't need that tool .

Go on zerotier dashboard and create a new network, 
```shell
sudo zerotier-cli join YOU_NETWORK_ID
```

Now go to Zerotier dashboard and accept your new machine

## Step one - Install Geth

```shell
sudo apt-get install software-properties-common
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install ethereum
```

## Creation of bootnode

### Creation of boot.key file

```shell
bootnode -genkey boot.key
```
This file contain your enode id which will be necessary for further connections

On the OVH server named ``ns3101730.ip-54-36-123.eu`` the enode id is :
``enode://c21578a1ce85a31c5e221b2ef264ba9e12459ac4b69c9a5fc9bd063c1ab1187ab197e63022ea83b3010a11794169e1e7ffa4bf1fb8bf41b82b978de297cbbe3b@<SERVER-IP>?discport=30310``

Change the ``<SERVER-IP>`` to the ip of your server. The IP of the OVH bootnode named ``ns3101730.ip-54-36-123.eu`` is ``192.168.191.84``.

### Bootnode launch

You need first to install supervisor to keep your process up and running

```shell
apt-get install supervisor
```

Now create a file geth.conf and place it in the following folder : ``/etc/supervisor/conf.d``

```shell
vim /etc/supervisor/conf.d/geth.conf
```

Copy/paste the following :

```shell
[program:geth_client]
command=bootnode -nodekey /root/boot.key -verbosity 9 -addr :30310
autostart=true
autorestart=true
stderr_logfile=/root/getherr.log
stdout_logfile=/root/gethlog.log
```
Tell supervisor to take into account the new configuration:

```shell
supervisorctl reread

supervisorctl update
```

You can check if the supervisor job is running correctly by running the following command:

```shell
supervisorctl status
```

**Tip:** You can access more commands for supervisor by using its CLI:
```shell
supervisorctl
```
In this cli, several commands are available, type ``help`` for details.


## Creation of casual node (Sealer AND transactionner)

### Step 1 - Create create an ethereum account

**Note:** THe following command will automatically create the ``datadir`` folder.

```shell
geth account new --datadir datadir
```

### Step 2 - Store the account password

Create a file and store the password used to create the new ethereum account with the following command:

```shell
vim /root/datadir/password.txt
```

### Step 3 - Create genesis.json file

Get the genesis.json file from the github repository. It is available [here](genesis.json).

Create the genesis.json file on the node with the following command:
```shell
vim /root/genesis.json
```

### Step 4 - Initialize the genesis block

Run the following command:
```shell
geth --datadir ./datadir init ./genesis.json
```

-----

### Step 5 - Launch your node

#### Install ``supervisor``, the process manager

Run the following command:
```shell
apt-get install supervisor
```

-----

#### Create a ``supervisor`` process configuration file

Run the following command:

You need first to install supervisor to keep your process up and running

```shell
apt-get install supervisor
```

Now create a file geth.conf and place it in the following folder : ``/etc/supervisor/conf.d``

```shell
vim /etc/supervisor/conf.d/geth.conf
```

##### Launch regular node

```shell
[program:geth_client]
command=geth --datadir /root/datadir/ --syncmode 'full' --port 30311 --rpc --rpcaddr '0.0.0.0' --rpcport 8501 --rpcapi 'personal,db,eth,net,web3,txpool,miner,admin,clique' --bootnodes '<BOOTNODE-ENODE>' --networkid 1100 -unlock '<ACCOUNT-ADDRESS>' --password /root/datadir/password.txt --mine --allow-insecure-unlock
autostart=true
autorestart=true
stderr_logfile=/root/getherr.log
stdout_logfile=/root/gethlog.log
```

- ``<BOOTNODE-ENODE>``: The enode of the bootnode you previoulsy created, or the enode of the bootnode that already exists.
- ``<ACCOUNT-ADDRESS>``: The account address that you created previously in [step 1](#step-1---create-create-an-ethereum-account).

For those nodes, RPC API is activated to allow client application to interact with the blockchain.


Tell supervisor to take into account the new configuration:

```shell
supervisorctl reread

supervisorctl update
```

You can check if the supervisor job is running correctly by running the following command:

```shell
supervisorctl status
```

**Tip:** You can access more commands for supervisor by using its CLI:
```shell
supervisorctl
```
In this cli, several commands are available, type ``help`` for details.

Your node is now up and running. If everything is going well, you can check the file ``/root/getherr.log``. It will contain all the logs of the node. If the synchronization is working, you should see in the logs that it reached a block number different than 1.

**Note:** The node you set up is not an active block sealer. If you want your node to be able to seal blocks, follow the next section. Otherwise, you are done.

### Give the sealer role to your new node

By default, a node that joined the an existing PoA blockchain network is not a sealer. To add a new sealer node to the network, more than half (<50%) of the current sealers must explicitely give the role to the new node.

**Note:**: Initial sealers are defined in the genesis.json file, in the ``extraData`` property.

**Note:** The following procedure is manual. In the future, a more easy/beautiful way to do this can be implemented.

**Note:** You must repeat the next steps on more than 50% of the current sealer nodes.

#### Access the sealer RPC API

Access via SSH to the sealer:

```shell
ssh <NAME>@<IP>
```

Access the RPC API:

```shell
geth attach 'http://localhost:8501'
```

**Note:** If you have geth installed on your own machine, you can skip the ssh part and attach to the node with a command similar to the following. MAKE SURE THAT YOU ARE INSIDE THE ZEROTIER VPN:

```shell
geth attach 'http://<NODE-IP>:8501'
```

#### Propose the new account/node to be a sealer

You are now in the geth CLI of the node. You have access to several APIs depending on the node you accessed. Every node currently have access to the ``clique`` API.

The command to propose the new node as a sealer is the following:

```shell
clique.propose('<ACCOUNT-ADDRESS>', true)
```

- ``<ACCOUNT-ADDRESS>``: The account address of the node to add as a sealer.

**Note:** This command won't have any effect until more than 50% of the sealers executed it.
