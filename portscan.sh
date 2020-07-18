#!/bin/bash
DIR=$1/scope

### Filter out IP address from the IP list ###
cat $DIR/ip_hosts.txt | jq '.data.answers' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort -u > $DIR/ip.txt

### Run masscan ### 
sudo masscan -iL $DIR/ip.txt -p0-1000 -oX $DIR/masscan.txt
