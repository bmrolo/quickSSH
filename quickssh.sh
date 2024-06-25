#!/bin/bash

echo "Where are you trying to go?"
echo -n "| d = Most Recent Download | f = Search Downloads | h = Home |"
echo
read destination
if [[ "$destination" == "d" ]]; then
    checkPath="$HOME/Downloads"
    ssh_key=$(ls -t $HOME/Downloads/*.pem | head -n 1)
elif [[ "$destination" == "f" ]]; then
    checkPath="$HOME/Downloads"
    cd $checkPath
    ssh_key=$(fzf --height=~100% --layout=reverse-list --query ".pem$ !Library")
elif [[ "$destination" == "h" ]]; then
    checkPath="$HOME"
    cd $HOME
    ssh_key=$(fzf --height=~100% --layout=reverse-list --query ".pem$ !Library")
elif [[ -z "${destination}" ]]; then
    exit 1
fi
if [[ -z "${ssh_key}" ]]; then
    echo "No SSH key selected! Exiting"
    exit 1
chmod 400 $ssh_key
echo -n 'Enter Public IP: '
read ec2_ipaddress
echo
echo -n 'Enter User: (Press Enter for ec2-user) '
read vm_user
if [ -z "$vm_user" ]; then
    vm_user="ec2-user"
fi
echo
echo "Using $(basename $ssh_key) as $vm_user to SSH into $ec2_ipaddress..."
echo
ssh -i $ssh_key $vm_user@$ec2_ipaddress
