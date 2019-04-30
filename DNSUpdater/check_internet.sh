#!/bin/bash

log() {
        if [ "$1" ]; then
                echo "[$(date)] - $1" >> /home/pi/DNSUpdater/logs/cloudflare.log #Change to Actual Path
        fi
}
ifonline() {
        log "Internet is up and running"
        exit
}

ifoffline() {
        log "Internet seems to be offline... Trying again."
}
for t in {1..3}
do
        for i in {1..5}
        do
                (ping -q -w1 -c1 google.com &>/dev/null) && ifonline || ifoffline
        done
        if [ $t = 3 ]
        then
                break
        fi
        log "Internet found to be offline. Restarting Network"
        sudo service networking restart
done
log "Internet connection cannot be restored. Restarting machine."
echo "[$(date)] - Machine restarting - No interent connectivity" >> /home/pi/DNSUpdater/logs/error.log #Change to Actual Path
sudo reboot
