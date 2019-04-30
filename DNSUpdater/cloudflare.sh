##!/bin/bash

Path=$1
# CHANGE THESE
auth_email=""
auth_key="" # found in cloudflare account settings

get_zones="https://api.cloudflare.com/client/v4/zones"
get_dnss="dns_records"
ch_XAE="X-Auth-Email: $auth_email"
ch_XAK="X-Auth-Key: $auth_key"
ch_CT="Content-Type: application/json"

checkresponse() {
        eval row="$1" # Evaluate white spaces.
        row=$(echo $row | jq -r '.success') # Get success
        success=$(echo $row)
        if $success ; then
                return 0
        else
                return 1
        fi
        return 1
}

getzones() {
        zones=$(curl -s -X GET "$get_zones" -H "$ch_XAE" -H "$ch_XAK" -H "$ch_CT")
        if checkresponse "\${zones}" ; then
                for row in $(echo "${zones}" | jq -r '. | @base64'); do
                        _jq() {
                                echo ${row} | base64 --decode | jq -r $1
                        }
                        z_id=$(_jq '.result[].id')
                        for zone in $z_id ; do
                                getrecords $zone
                        done
                done
        else
                log "Zones query NOT successful, please see Error log file for full analysis"
                log "Error: Zones response returned the following message: $zones" "error"
        fi
}

getrecords() { # $1=zone_identifier
        records=$(curl -s -X GET "$get_zones/$1/$get_dnss?type=A" -H "$ch_XAE" -H "$ch_XAK" -H "$ch_CT")
        if checkresponse "\${records}" ; then
                for row in $(echo "${records}" | jq -r '. | @base64'); do
                        _jq() {
                                echo ${row} | base64 --decode | jq -r "${1}"
                        }
                        r_id=$(_jq '.result[].id')
                        mapfile -t r_type < <(_jq '.result[].type')
                        mapfile -t r_name < <(_jq '.result[].name')
                        mapfile -t r_content < <(_jq '.result[].content')
                        i=0
                        for record in $r_id ; do
                                updatedns $1 $record "${r_type[i]}" "${r_name[i]}" "${r_content[i]}"
                                ((i++))
                        done
                done
        else
                log "Records query was NOT successful, please check error log file for full analysis"
                log "Error: Records response returned the following message: $records" "error"
        fi
}

updatedns() { # $1=zone_identifier $2=record_identifier $3=record_type $4=record_name $5=record_content
        new_ip=$(cat "${Path}/ip.txt")
        if [[ $new_ip == $5 ]] ; then
                log "IP is already $5 for $4."
        else
                update=$(curl -s -X PUT "$get_zones/$1/$get_dnss/$2" -H "$ch_XAE" -H "$ch_XAK" -H "$ch_CT" --data "{\"type\":\"$3\",\"name\":\"$4\",\"content\":\"$new_$
                if checkresponse "\${update}" ; then
                        log "Successfully changed IP from $5 to $new_ip : $4."
                else
                        log "$4 : Could not change the record. Please check error log file for full analysis."
                        log "Error: Update DNS response returned false\n\n Data sent: \nz_id = $1 \nr_id = $2 \nr_type = $3 \nr_name = $4 \nr_content = $5 . \ncurl ret$
                fi
        fi
}

ip=$(cat "${Path}/ip.txt")
log_file="${Path}/logs/cloudflare.log"
log_file_dir="${Path}/logs/"

# LOGGER
log() {
    if [ "$2" ]; then
                echo -e $(echo -e "[$(date)] - $1" >> "$log_file_dir$2.log")
                return
        fi
        if [ "$1" ]; then
                echo "[$(date)] - $1" >> $log_file
        fi
}

log "Check Initiated"

getzones
