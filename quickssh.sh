#!/bin/bash

echo -n "Enter Public IP (or press Enter to search with AWS CLI): "
read ec2_ipaddress
if [ -z "$ec2_ipaddress" ]; then
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI is not installed. Please install it first."
        exit 1
    fi

    # Get the list of EC2 instances
    instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value | [0], InstanceId, KeyName, PublicIpAddress]' --output text)

    # Check if there are any instances
    if [ -z "$instances" ]; then
        echo "No EC2 instances found."
        exit 1
    fi

    # Display the list of instances and prompt the user to select one
    echo "Available EC2 instances:"
    instance_count=0
    while read -r instance; do
        instance_count=$((instance_count + 1))
        instance_details=($instance)
        printf "%2d: NAME: %s  ID: %s  KEY: %s  IP: %s\n" "$instance_count" "${instance_details[0]}" "${instance_details[1]}" "${instance_details[2]}" "${instance_details[3]}"
    done <<< "$instances"

    echo -n "Enter the instance number you want to connect to: "
    read instance_number

    # Validate the user input
    if ! [[ "$instance_number" =~ ^[0-9]+$ ]] || [ "$instance_number" -lt 1 ] || [ "$instance_number" -gt "$instance_count" ]; then
        echo "Invalid instance number selected."
        exit 1
    fi

    # Get the selected instance details
    selected_instance=$(echo "$instances" | awk -v line="$instance_number" 'NR == line')
    selected_instance_details=($selected_instance)
    ec2_ipaddress="${selected_instance_details[3]}"
    selected_key_name="${selected_instance_details[2]}"
fi

echo "Where is your SSH key located?"
echo -n "| 1 = Most Recent Download | 2 = Search Downloads | 3 = Home | 4 = Custom Path |"
echo
read key_location

if [[ "$key_location" == "1" ]]; then
    checkPath="$HOME/Downloads"
    ssh_key=$(ls -t $HOME/Downloads/*.pem | head -n 1)
elif [[ "$key_location" == "2" ]]; then
    checkPath="$HOME/Downloads"
    cd $checkPath
    if [ -n "${selected_key_name}" ]; then
        ssh_key=$(fzf --height=~100% --layout=reverse-list --query ".pem$ !Library ${selected_key_name}")
    else
        ssh_key=$(fzf --height=~100% --layout=reverse-list --query ".pem$ !Library")
    fi
elif [[ "$key_location" == "3" ]]; then
    checkPath="$HOME"
    cd $HOME
    if [ -n "${selected_key_name}" ]; then
        ssh_key=$(fzf --height=~100% --layout=reverse-list --query ".pem$ !Library ${selected_key_name}")
    else
        ssh_key=$(fzf --height=~100% --layout=reverse-list --query ".pem$ !Library")
    fi
elif [[ "$key_location" == "4" ]]; then
    echo -n "Enter the custom directory path: "
    read custom_path
    checkPath="$custom_path"
    cd "$custom_path"
    if [ -n "${selected_key_name}" ]; then
        ssh_key=$(fzf --height=~100% --layout=reverse-list --query ".pem$ !Library ${selected_key_name}")
    else
        ssh_key=$(fzf --height=~100% --layout=reverse-list --query ".pem$ !Library")
    fi
elif [[ "$key_location" == "h" ]]; then
    checkPath="$HOME"
    cd $HOME
    if [ -n "${selected_key_name}" ]; then
        ssh_key=$(fzf --height=~100% --layout=reverse-list --query ".pem$ !Library ${selected_key_name}")
    else
        ssh_key=$(fzf --height=~100% --layout=reverse-list --query ".pem$ !Library")
    fi
elif [[ -z "${key_location}" ]]; then
    echo "No key location selected! Exiting"
    exit 1
fi

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
