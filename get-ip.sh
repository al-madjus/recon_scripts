#!/bin/bash
DIR=$1

### Remove http:// and https:// ###
sed -e 's/http:\/\///g' -e 's/https:\/\///g' -e 's/.*/\L&/' $DIR/scope/alive.txt > $DIR/scope/alive.tmp

### Run zdns from above file ###
zdns A --name-servers=1.1.1.1 -input-file $DIR/scope/alive.tmp -output-file $DIR/scope/ip_hosts.txt

### Clean up ###
rm $DIR/scope/alive.tmp
