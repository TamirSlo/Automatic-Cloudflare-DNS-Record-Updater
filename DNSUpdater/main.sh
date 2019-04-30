#!/bin/sh

# Variables
Path="/home/pi/DNSUpdater" #ENTER HERE FULL PATH e.g. /home/pi/DNSUpdater
SUBJ="IP_Changed" #EMail Subject
EMAIL="ENTER YOUR EMAIL ADDRESS HERE" #Email Address to send notification

check_internet() {
  bash "${Path}/check_internet.sh" "${Path}"
}

update_cf() {
  bash "${Path}/cloudflare.sh" "${Path}"
}

log() {
        if [ "$2" ]; then
                echo $(echo "[$(date)] - $1" >> "${Path}/logs/$2.log")
                return
        fi
        if [ "$1" ]; then
                echo "[$(date)] - $1" >> "${Path}/logs/cloudflare.log"
                return
        fi
}

ip1=""
ip2=""
echo "\n" >> "${Path}/logs/cloudflare.log"
localip=$(ip addr show eth0 | grep 'inet' | awk '{print $2}' | cut -f1 -d'/' | head -n 1)

read ip1 < "${Path}/ip.txt"
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
