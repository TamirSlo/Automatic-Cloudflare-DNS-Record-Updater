#!/bin/sh

# Variables
log_file_cloud="PATH" #ENTER HERE FULL PATH e.g. /home/pi/DNSUpdater/logs/cloudflare.log
log_file_dir="PATH_TO_LOG_DIRECTORY" #ENTER HERE FULL PATH TO LOG DIRECTORY e.g. /home/pi/DNSUpdater/logs/
ip_file="PATH_TO_IP_FILE" #ENTER HERE FULL PATH TO LOG DIRECTORY e.g. /home/pi/DNSUpdater/ip.tkt
SUBJ="IP_Changed" #EMail Subject
EMAIL="ENTER YOUR EMAIL ADDRESS HERE" #Email Address to send notification

check_internet() {
  bash /home/pi/DNSUpdater/check_internet.sh #CHANGE TO Actual Path
}

update_cf() {
  bash /home/pi/DNSUpdater/cloudflare.sh #CHANGE TO Actual Path
}

log() {
        if [ "$2" ]; then
                echo $(echo "[$(date)] - $1" >> "$log_file_dir$2.log")
                return
        fi
        if [ "$1" ]; then
                echo "[$(date)] - $1" >> $log_file_cloud
                return
        fi
}

ip1=""
ip2=""
echo "\n" >> $log_file_cloud
localip=$(ip addr show eth0 | grep 'inet' | awk '{print $2}' | cut -f1 -d'/' | head -n 1)

read ip1 < $ip_file
ip2=$(wget -qO- ifconfig.me/ip)
rip="$ip2"
log "IP Checker script is running"

if [ "$ip2" = "" ] ;then
        log "Error fetching remote IP" "error"
        log "\nLocal IP: $localip - Remote IP: $rip\n" "iphistory"
        check_internet
elif [ "$ip1" = "$ip2" ] ;then
        log "Local IP: $localip - Remote IP: $rip" "iphistory"
        check_internet
        exit
else
        echo "$ip2" > $ip_file
        log "IP seems to have changed from $ip1 to $ip2"
        log "Local IP: $localip - Remote IP: $rip" "iphistory"
        check_internet
        update_cf
        mail -s $SUBJ $EMAIL <<< "This is an automated message from the RaspberryPi DNSUpdater for CloudFlare script. The IP has been changed to $ip2"
        exit
fi
