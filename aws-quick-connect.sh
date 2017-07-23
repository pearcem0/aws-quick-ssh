#!/bin/bash
#serverlist=".ServerList"
serverlist=".ServerList"
user="ec2-user"

function init() {

if [ -z "$serveralias" ]
then
  echo "Error! Please provide server alias (-s myserver)"
else
  echo "Server alias is: $serveralias"
fi

if [ -z "$keypair" ]
then
  echo "Error! Please provide ssh keypair (-k keypair.pem)"
else
  echo "Using keypair: $keypair"
fi

if [ -z "$awsprofile" ]
then
  echo "Error! Please provide aws profile (-p my-aws-profile)"
else
  echo "Running as aws profile: $awsprofile"
fi

servername=`getServerName`
if [ -z "$servername" ]
then
  echo "Error! Can't find servername. Make sure you add it to the template file."
  exit 1
else
  echo "Servername is : $servername"
  connect
fi

}

function connect() {

  IPAddress=`getLastIP $servername`
  if [ -z "$IPAddress" ]
  then
    getNewIP
  else
    ssh -i $keypair $user@$IPAddress || reconnect
  fi
  # check hostname
}

function reconnect() {
  echo "Starting reconnect()"

  getNewIP
  IPAddress=`getLastIP $servername` || echo "can't find IP"
  echo "Attempting to reconnect with $IPAddress"
  ssh -i $keypair $user@$IPAddress
}

function getServerName() {
  cat $serverlist | grep $serveralias | cut -d ":" -f 2 | cut -d "=" -f 1 | head -1
}

function getLastIP() {
  cat $serverlist | grep $servername | cut -d "=" -f 2
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

while getopts ":s:k:p:u:" opt; do
  case $opt in
    s)
      serveralias=$OPTARG
      ;;
    k)
      keypair=~/.ssh/$OPTARG
      ;;
    p)
      awsprofile=$OPTARG
      ;;
    u)
      user=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

init
