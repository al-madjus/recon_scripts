#!/bin/bash

DIR=$1
TARGET=$2
WORDLIST_PATH="/usr/share/wordlists"

# Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

# Functions
banner(){
	name=$1
	echo -e "${RED}\n[*] Running $name...${RESET}"
}

### Subdomain enumeration ###
banner "Amass"
amass enum -brute -min-for-recursive 2 -d $TARGET -r 8.8.8.8 -o $DIR/scope/amass.txt 
# Clean up
sed -i 's/target--//g' $DIR/scope/amass.txt

findomain -q -t $TARGET > $DIR/scope/findomain.txt

### Merge files ###
cat $DIR/scope/amass.txt $DIR/scope/findomain.txt >> $DIR/scope/scope.txt
sort -uo $DIR/scope/scope.txt $DIR/scope/scope.txt

### Clean up ###
rm $DIR/scope/amass.txt $DIR/scope/findomain.txt

echo -e "Found number of subs:"
wc -l  $DIR/scope/scope.txt

### Find which subs are alive ### 
banner "httprobe"
cat $DIR/scope/scope.txt | httprobe --prefer-https -c 10 > $DIR/scope/alive.txt

### Create list of dead subs for future checking ###
sed -e 's/http:\/\///g' -e 's/https:\/\///g' -e 's/.*/\L&/' $DIR/scope/alive.txt > $DIR/scope/alive.tmp
grep -Fxvf $DIR/scope/alive.tmp $DIR/scope/scope.txt > $DIR/scope/dead.txt
rm $DIR/scope/alive.tmp
