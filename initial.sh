#!/bin/bash

DIR=$1
#TARGET=$2
WORDLIST_PATH="/usr/share/wordlists"
TODAY=$(date + %d%m%Y)

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
while read p; do amass enum -brute -min-for-recursive 2 -d $p -r 8.8.8.8 -o $DIR/scope/amass.txt 
# Clean up
sed -i 's/target--//g' $DIR/scope/amass.txt

findomain -q -t $p > $DIR/scope/findomain.txt

### Merge files ###
cat $DIR/scope/amass.txt $DIR/scope/findomain.txt >> $DIR/scope/scope.txt; done < $DIR/scope/domains.txt
sort -uo $DIR/scope/scope.txt $DIR/scope/scope.txt

### Remove out of scope domains ###
while read p; do sed -i "/$p/d" $DIR/scope/scope.txt; done < $DIR/scope/oos.txt

### Clean up ###
rm $DIR/scope/amass.txt $DIR/scope/findomain.txt

echo -e "Found number of subs:"
wc -l  $DIR/scope/scope.txt

### Backup alive subs ###
cp $DIR/scope/alive.txt $DIR/scope/alive.old

### Find which subs are alive ### 
banner "httprobe"
cat $DIR/scope/scope.txt | httprobe --prefer-https -c 10 > $DIR/scope/alive.txt

### Create list of dead subs for future checking ###
sed -e 's/http:\/\///g' -e 's/https:\/\///g' -e 's/.*/\L&/' $DIR/scope/alive.txt > $DIR/scope/alive.tmp
grep -Fxvf $DIR/scope/alive.tmp $DIR/scope/scope.txt > $DIR/scope/dead.txt
rm $DIR/scope/alive.tmp

### Display all the new subs ###
echo "### $1 ###" >> $DIR/../_results/subs-$TODAY.txt
echo -e "These are the new subdomains found:"
#echo "New subdomains: " >> ~/output-$TODAY.txt
grep -F -x -v -f $DIR/scope/alive.old $DIR/scope/alive.txt | tee -a $DIR/../_results/subs-$TODAY.txt
rm $DIR/scope/alive.old
