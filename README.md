# aws-quick-ssh

# about aws-quick-ssh
* Quickly ssh into one of your many AWS EC2 instances using an alias, when the IP address is subject to frequent change
* Store latest IP address for each server to connect straight away
* Or query the AWS api to find the IP address of the server you need
* Update the saved IP address for next time

# prerequisites & assumptions
* You have installed and configured awscli (used for describe-instances api calls etc.)
* Required ssh keys are held at ~/.ssh/
* Login user is `ec2-user` (This will probably be easier to change in future, but you can change the script if you need)
* You have filled in the template of servers you connect to most often (`.ServerList`)

# usage
* Fill in the server list template (`.ServerList`) with the servers you connect to most.
* If you want to use a different or several server list(s), you can change the `$serverlist` variable
* `aws-quick-ssh servername_alias sshkeyname aws-profilename`

# further usage
* You may choose to run the script as part of your shell aliases so that you don't have to type the same parameters each time

# disclaimer
* For personal use and development - may not work for you, but feel free adapt as necessary

# Ideas
* Fetch aws profile names from `~/.aws/config`
* Allow different login users
* Build in possible use of different or multiple serverlist template files
