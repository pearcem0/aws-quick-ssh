#!/bin/bash
serverlist=".ServerList"

function init() {
serveralias=$1
servername=`getServerName $1`
keypair="~/.ssh/$2"
awsprofile=$3
echo "Connecting to server: $servername"
echo "Using keypair: $keypair"
echo "Running as aws profile: $awsprofile"

}

function connect() {
  IPAddress=`getLastIP $servername` || getNewIP $1 $3
  echo "Attempting to connect to $IPAddress"
  ssh -i $keypair ec2-user@$IPAddress || reconnect $servername $2 $3
  # check hostname
}

function reconnect() {
  getNewIP $servername $3
  IPAddress=`getLastIP $servername` || echo "can't find IP"
  echo "Attempting to reconnect with $IPAddress"
  ssh -i $keypair ec2-user@$IPAddress
}

function getServerName() {
  cat $serverlist | grep $1 | cut -d ":" -f 2 | cut -d "=" -f 1 | head -1
}

function getLastIP() {
  cat $serverlist | grep "$servername" | cut -d "=" -f 2
}

function addToIPList() {
 # remove the old ip first
 cat $serverlist | grep $servername | sed -i.bak "/$servername/d" $serverlist
 # add the new one
 echo "$serveralias:$servername=$1" | cat >> $serverlist && echo Added new IP
}

function removeIP() {
  cat $serverlist | grep $servername | sed -i.bak "/$1/d" $serverlist
}

function getNewIP() {
  echo Getting new IP...
  newIPAddress="`aws ec2 --profile $awsprofile describe-instances --output table \
  --filters "Name=tag:Name,Values=$servername" | grep -m 1 PrivateIpAddress \
  | awk '{ print $4 ;}'`" && echo New IP fetched successfully, new IP is $newIPAddress
  addToIPList $newIPAddress
}

init $1 $2 $3
connect $servername $keypair $awsprofile
