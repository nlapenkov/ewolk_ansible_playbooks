#!/bin/bash
# This program scans the /var/log/messages file for new dhcp leases If new leases is found, 
#you can do something with it, see comments in script Script was made by dev-random.net Make 
#sure this script is not already running
lf=/var/lock/look_for_new_devices.lock
# create empty lock file if none exists
touch $lf read lastPID < $lf
# if lastPID is not null and a process with that pid exists , exit
[ ! -z "$lastPID" -a -d /proc/$lastPID ] && exit
# save my pid in the lock file
echo $$ > $lf
#Endless loop.
while true; do
	
	#example line from log: Dec 5 10:28:26 router dhcpd: DHCPOFFER on 172.16.1.207 to 
	#00:00:00:00:00:00 (hostname) via eth1.21
	IPS=`logtail -f /var/log/syslog | grep "DHCPOFFER on" | awk '{ print $8 }'`
	#for each ip found in the log that was send out as a dhcp offer
		for ip in $IPS; do
		mac=`grep "DHCPOFFER on" /var/log/syslog | tail -n 1 | awk '{ print $10 }'`
		port=`grep "$ip" /etc/network/if-pre-up.d/iptables | awk '{ print $11; exit }' |cut -c 2-`
                id=`grep -irl "$mac" /etc/pve/nodes/ | cut -d/ -f7 |  sed s/[^0-9]//g`
		#curl -d "ip=$ip&mac=$mac&port=$port" "https://my.ewolk.net/api/1.0/wf/get_ip"
#		echo $ip,$mac,$port,$(date +"%y-%m-%d-%T") >> /var/www/html/mas.csv
                echo $ip,$mac,$port,$id,$(date +"%y-%m-%d-%T") >> /mnt/pve/nfsstorage/mas.csv
		
		
		
		#Do your magic with the ip here I am running another script to scan the ip 
		#and put it into a database so I can use it for other fun stuff like 
		#searching in a web interface.
		
		
		
		
	done
	
	#sleep a little while to allow something to happen before we check again
        #This script will check for new ip's in the log file every 10 seconds and execute 
        #whatever you tell it to do when a new ip is found.
	sleep 1
done
