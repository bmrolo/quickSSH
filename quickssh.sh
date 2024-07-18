#!/bin/bash

# Check all dependencies
dependencies=("fzf" "jq" "aws")
for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        echo "$dep is not installed. Please install it first."
        exit 1
    fi
done


echo -n "Enter Public IP (or press Enter to search with AWS CLI): "
read ec2_ipaddress
if [ -z "$ec2_ipaddress" ]; then
    # Get the list of EC2 instances
    instances=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0], InstanceId, KeyName, PublicIpAddress]' --output json)
    num_instances=$(($(echo "$instances" | jq length)))

    # Check if there are any instances
    if [ -z "$instances" ]; then
        echo "No EC2 instances found."
        exit 1
    fi

    # Display the list of instances and prompt the user to select one
    echo "Available EC2 instances:"
    instance_iteration_count=1
    for i in $(seq 1 $num_instances); do
        instance_name=$(echo "$instances" | jq -r ".[$instance_iteration_count-1][0]")
        instance_id=$(echo "$instances" | jq -r ".[$instance_iteration_count-1][1]")
        instance_key=$(echo "$instances" | jq -r ".[$instance_iteration_count-1][2]")
        instance_ip=$(echo "$instances" | jq -r ".[$instance_iteration_count-1][3]")
        printf "%2d: NAME: %s  ID: %s  KEY: %s  IP: %s\n" "$instance_iteration_count" "$instance_name" "$instance_id" "$instance_key" "$instance_ip"
        instance_iteration_count=$((instance_iteration_count + 1))
    done

    echo -n "Enter the instance number you want to connect to: "
    read instance_number

    # Validate the user input
    if ! [[ "$instance_number" =~ ^[0-9]+$ ]] || [ "$instance_number" -lt 1 ] || [ "$instance_number" -gt "$instance_iteration_count" ]; then
        echo "Invalid instance number selected."
        exit 1
    fi

    # Get the selected instance details
    selected_instance=$(echo "$instances" | jq -r ".[$instance_number-1]")
    ec2_ipaddress=$(echo "$selected_instance" | jq -r ".[3]")
    selected_key_name=$(echo "$selected_instance" | jq -r ".[2]")

fi

echo "Where is your SSH key located?"
echo -n "| 1 = Most Recent Download | 2 = Search Downloads | 3 = Current Directory | 4 = Custom Path |"
echo
read key_location

get_ssh_key() {
    if [ -n "${selected_key_name}" ]; then
        ssh_key=$(fzf --height=~100% --layout=reverse-list --query ".pem$ !Library ${selected_key_name}")
    else
        ssh_key=$(fzf --height=~100% --layout=reverse-list --query ".pem$ !Library")
    fi
}

case "$key_location" in
    1)
        checkPath="$HOME/Downloads"
        ssh_key=$(ls -t "$HOME/Downloads"/*.pem | head -n 1)
        ;;
    2)
        checkPath="$HOME/Downloads"
        cd "$checkPath" || exit
        get_ssh_key
        ;;
    3)
        checkPath="$PWD"
        get_ssh_key
        ;;
    4)
        echo -n "Enter the custom directory path: "
        read custom_path
        checkPath="$custom_path"
        cd "$checkPath" || exit
        get_ssh_key
        ;;
esac

if [[ -n "${ssh_key}" ]]; then
    chmod 400 "$ssh_key"
    echo -n 'Enter User: (Press Enter for ec2-user) '
    read vm_user
    if [ -z "$vm_user" ]; then
        vm_user="ec2-user"
    fi
    echo
    echo "Using "$ssh_key" as $vm_user to SSH into $ec2_ipaddress..."
    echo
    ssh -i "$ssh_key" $vm_user@$ec2_ipaddress
else
    echo "No SSH key selected! Exiting"
    exit 1
fi
