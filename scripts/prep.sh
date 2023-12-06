#!/usr/bin/env bash

# Check if PermitRootLogin is disabled

if sudo grep -Fqx 'PermitRootLogin no' /etc/ssh/sshd_config >/dev/null 2>&1 ; then
	sudo sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
fi


# Check if PasswordAuthentication is disabled

if sudo grep -Fqx 'PasswordAuthentication no' /etc/ssh/sshd_config >/dev/null 2>&1 ; then
	sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
fi

# Have the user set their root password

echo "Prepare to set your root password:"

sudo passwd
