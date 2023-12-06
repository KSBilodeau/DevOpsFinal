#!/usr/bin/env bash

# Allow the user to specify the time between runs
read -p "Enter cronjob time setting: (* * * * *) " strRepeat

# Run the cron job once
eval "cd $(cat ~/.working_dir.txt) && echo 'dev' | ./scripts/setup.sh"

# Delete pre-existing cron jobs
crontab -r 
# Replace it with new cronjob
(crontab -l 2>/dev/null; echo "$strRepeat eval 'cd \$(cat ~/.working_dir.txt) && echo 'test' | ./scripts/setup.sh'") | crontab -

