# DEV OPS FINAL PROJECT

When it comes to setting up a swathe of servers, it is important
to have some powerful tooling behind you.  As such, we here at
K Corp Industries have come to provide you with the finest in 
automated automation installation maintenance technologies.

## Table Of Contents

1. [Installation](#installation-instructions)
2. [Maintenance](#maintenance)
3. [Potential Issues](#potential-issues)

## Installation Instructions

### Preface:

In order to properly implement this system, you will 
need 3 servers/vms.  One shall act as the controller,
also known as the ansible machine, and the other two 
will be web servers. Servers/VM groupings greater than 3 will have 
one database webserver, and the rest will be normal apache and nodeJS 
web servers. As part of this system, one of the web 
servers will be equipped with MariaDB as well as the base Apache 
and nodeJS packages.  This system does not have any interaction
between dev/prod/test, so this can be applied over any number of 
triplet dev/prod/test clusters.  It can also be applied to as little
as a single triplet+ prod server, if you so wished.

### Requirements

It is strongly recommended that the web servers operate using 
debian, and the ansible machine operate using a RHEL based OS;
however, the only actual requirement is that the web servers
are equipped with the apt package manager - by whatever means
deemed necessary.  Use of dark forces and or programs beyond 
what any mortal being voids all warranty of this software working.
It is also important to have a near fresh image and unused 
VM in order for this to work optimally. The scripts are designed
to have as minimal impact as possible, but there are unavoidable 
**destructive** portions that may interfere with other 
user created processes/systems.

Aside from the architectural requirements, Git will be needed 
on the ansible machine as well as wget on the web servers.  It
is possible to perform this installation process without this 
software, however, it would mean having the ability to transfer
files by some means outside of SSH or SFTP.

### Step 1: Download prep.sh to your web servers and execute

This is the most manual and tedious aspect of this process.
However, it is a million times easier than the likely several
hours I wasted time doing it manually over and over again.

To complete this step of the installation process (assuming
you have already installed wget as previously indicated), you 
will need to run the following command on every webserver
you will be using:

```bash
$ wget https://github.com/KSBilodeau/DevOpsFinal/raw/main/scripts/prep.sh
```

This will give you a script designed to allow your managaement
server a much easier time connecting and transmitting some
crucial SSH information without needing pesky keys up front.

Once it is downloaded, you are going to need to run this command:

```bash
$ chmod +x prep.sh && ./prep.sh
```

This will make the script executable and run it, at which point
you should be prompted to enter a new root password.  This is 
part of the reason why it is important to have a near fresh VM.

### Step 2: Clone this repository

Moving to your ansible machine - the great controller - you will 
need to run the following command:

```bash
$ git clone https://github.com/KSBilodeau/DevOpsFinal.git
```

Inside of the newly created folder, there will be a number of 
scripts named run_me_*.sh.  That script is the last thing you 
will need to run before your beautiful baby server cluster is off
to the races.

**IMPORTANT NOTE: DO NOT RUN ANY OF THE RUN_ME SCRIPTS UNTIL YOU 
ARE SURE THAT THE REPOSITORY IS IN A LOCATION YOU ARE OK WITH IT
STAYING FOR THE DURATION OF THE SYSTEM'S LIFE.**

Cron jobs are horribly picky, and this system relies on knowing 
where the repository is on installation in order to function.

### Step 3: Pick your target and execute the installation script

This system supports 3 named targets - dev, prod, test.  For these
3 targets, there are 3 aptly named scripts called run_me_dev.sh,
run_me_prod.sh, and run_me_test.sh.  

Once you have picked your target and are in the correct directory, 
simply run the following command (replacing * with your target name)
like so:

```bash
$ ./run_me_*.sh
```

This will prompt you for a number of things on first launch.  Of these
prompts, there is only one that really begs explanation.

### Cron time format

Along with being able to select your online repository to dynamically
grab your website and indicate, this system gives the user full control
over the cron scheduling functionality. In order to decide what string
to input, I will provide the very graph that helped me figure out how in 
the world this works:

![](https://cdn.shortpixel.ai/spai/q_glossy+w_1759+h_974+to_auto+ret_img/linuxiac.com/wp-content/uploads/2020/10/cron-job-format.png)

[Source: Linuxiac - WARNING: their website is brighter than the sun](https://linuxiac.com/cron-job-format/)

For example, once every minute is `* * * * *`, and once every day is `0 0 * * *`.  Units that are larger
than what you are aiming for can be left as stars.  There is also the division format that looks like
this: `*/30 * * * *`, which as I understand it means "per x unit".  In that case, it means the job will 
run every 30 minutes. 

Those who do not trust themselves or may just not be very saavy at this can use https://crontab.guru/
to calculate out the time codes.

### Step 4: Rejoice!  You did it!

In 1 quintillionth of the time it took to write this, you already have a fully connected
website system that is already hosting your wonderful website to the world.  That is 
really all that is to it.

The playbooks and scripts are all designed to be completely hands off.  Of course, the
code is documented for the curious or adventurous, but - in general - this is all you 
need to do from here on.  Any changes made to the website repository watched by the script
will be reflected on the next cron job iteration.

If you find that the cron job schedule you have picked is undesireable, simply run the 
run_me_*.sh script again, and it will allow you to set the cronjob to a new schedule.

## Maintenance

Ultimately, once you have setup the scripts, nothing needs to be done on any of the 
web servers.  Since the cronjobs persist across power cycles, you do not need to even
worry about rerunning the installation script if the ansible management server loses
power.  Once it comes back on, crontab will get right back to work executing autonomously.

## Potential Issues

There are a handful of potential issues that may arise over the course of 
utilizing this software.

1. If power is lost, the cron job timers may reset and cause your refresh to occur later than expected.
2. This system is heavily reliant on the internet working, so if you have an unstable connection between your serevrs, you may encounter irregularities.
3. Running 3+ servers can become very expensive very quickly.
4. All of the scripts use sudo and manipulate system files willy nilly, which is fine in isolation but catastrophic if mixed with the wrong programs.
5. Changing the targeted repository and IP addresses requires manually editing the /etc/ansible/hosts file.  Although, learning to edit the hosts file also allows for modifying the ratio of database servers to web servers.
6. Eval and SSH unencrypted plain text password tunnelling are used in this system.  Eval is shielded as best as I can; however, it is up to the user to disable password athentication and root login after the script copies the SSH keys over.
7. Intense sleep deprivation may have resulted in very odd decisions with very odd effects to be determined.
8. You attempt to use an SSH repo link for a repo you do not have SSH access to (or forgot to add the provided key when prompted to do so sometime before ansible floods the screen).  Just use https if you have the ability to for the sake of simplicity.
9. Your website repo branches do not follow a main, dev, test format. The scripts assume by selecting a specific target, you have a specific version of your page you would like to attach.  If not, prod maps to main so just use that instead.

In the case of the first issue, you can run the setup script under scripts/ to immediately run your playbook 
instead of waiting on the cron job to catch back up.  Aside from that, the rest of the problems are rather niche
or can be solved by either editing 5 lines of a config or running run_me_*.sh again.  You can rely on Keeg Corp 
to provide you a quality product that you can trust to work most of the time.
