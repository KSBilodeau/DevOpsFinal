#!/usr/bin/env bash

log () {
	echo -e $1 | sudo tee -a ~/deploy.log 
}

log "DATE OF EXECUTION: $(date '+%Y-%m-%d %H:%M:%S')"

if [ -d /var/www/html/.git ] ; then
	log "Updating repository..."

	cd /var/www/html
	git pull origin main

	log "Repository updated sucessfully!"
	exit 0
else
	log "Cloning repository..."
	rm -rf /var/www/html/*
	cd /var/www/html

	if git clone --branch $1 $2 . ; then
		log "Repository cloned successfully!"
		exit 0
	else
		log "Repository failed to clone!"
		exit 1
	fi
fi
