#!/usr/bin/env bash

check_installation() {
	if rpm -q $1 >/dev/null 2>&1 ; then
		echo "$1 is installed"
	else
		echo "Ansible not found; Installing..."

		if sudo yum install $1 -qy >/dev/null 2>&1 ; then
			echo "$1 is installed"
		else
			echo "ABORT: $1 failed to install"
			exit 1
		fi
	fi
}

log() {
	echo -e $1
	echo -e "$1" | sudo tee -a setup.log >/dev/null 2>&1
}

log_no_print() {
	echo -e "$1" | sudo tee -a setup.log >/dev/null 2>&1
}

# Mark date of execution in log

log "DATE OF EXECUTION: $(date '+%Y-%m-%d %H:%M:%S')"

# Check for necessary packages

log "Checking for necessary packages:\n"

check_installation ansible
check_installation git

log "\nAll packages installed!\n"

# Get the type of server we're configuring (test/dev/prod)

while true ; do
	read -p "Enter server type (test/dev/prod): " strServerType

	if [ $strServerType = "test" ] || [ $strServerType = "dev" ] || [ $strServerType = "prod" ] ; then
		break
	fi  

	log "Invalid Response: Try again"
done

log "Server type acquired: $strServerType\n"

log "Checking for prior system configuration:"

# Check if there are any IPs set in the ansible host file
# (meaning this script has been run before)

if sudo grep -qFx "[web$strServerType]" /etc/ansible/hosts >/dev/null 2>&1 ; then
	log "Ansible configuration found!"
else
	# Configure ansible with my defaults for test/prod/dev

	log "Ansible configuration not found!\nConfiguring ansible...\n"

	# Disable host key checking so that connections can be automated completely

	if grep -Fxq "#host_key_checking = False" /etc/ansible/ansible.cfg >/dev/null 2>&1 ; then
		sudo sed -i "s/#host_key_checking = False/host_key_checking = False/" /etc/ansible/ansible.cfg
		log_no_print "Disabled host key checking..."
	fi

	# Check if an SSH key is present

	if [ -f ~/.ssh/id_ed25519 ] ; then
		log_no_print "SSH key already present"
	else
		log_no_print "Generating SSH Key..."

		if yes "" | ssh-keygen -t ed25519 -N "" >/dev/null 2>&1 ; then
			eval "$(ssh-agent -s)" >/dev/null 2>&1
			ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1

			log_no_print "SSH key generated and added"
		else
			log_no_print "Failed to generate key"
			exit 2
		fi
	fi

	log "An SSH key was generated to assist you."
	log "Please enter the following into your online repo provider's SSH key entry system:"

	cat ~/.ssh/id_ed25519.pub

	echo

	# Get the IPs that are to be managed

	read -p "Enter the internal IPs to be managed as a space separated list: " strIpAddrs

	log "\nIPs to apply to hosts file:"

	# Convert the IP string into an array

	arrIpAddrs=( $strIpAddrs )

	i=1
	for ip in ${arrIpAddrs[@]} ; do
		log $ip

		# Append each IP address to the host file

		echo -e "\n[web${strServerType}${i}]\nroot@$ip" | sudo tee -a /etc/ansible/hosts >/dev/null 2>&1
		i=$(( $i + 1 ))
	done

	# Copy the keys to the servers

	log "\nPlease enter root passwd for each server: (IF NECESSARY)\n"

	for ip in ${arrIpAddrs[@]} ; do
		ssh-copy-id -i ~/.ssh/id_ed25519 root@$ip
		scp ~/.ssh/id_ed25519 root@$ip:~/.ssh
		scp ~/.ssh/id_ed25519.pub root@$ip:~/.ssh
		ssh root@$ip 'eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519'
	done

	echo
	read -p "Enter the address to your online repository: " strRepoAddr

	echo -e "\n[all:vars]\nrepo_addr=$strRepoAddr" | sudo tee -a /etc/ansible/hosts >/dev/null 2>&1
fi

log "\nRunning ansible test run..."

if ansible all -m ping ; then 
	log "Ansible ran successfully!"
else
	log "Ansible failed!"
	exit 3
fi























	
