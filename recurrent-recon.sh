#!/bin/bash
# Automated recurrent recon

DIR=$1/scope

### Check how many subs we already had ###
before=$(cat $DIR/alive.txt|wc -l)

### Backup alive subs ###
cp $DIR/alive.txt $DIR/alive.old

### Find which subs are alive ### 
echo -e "Finding active subdomains... "
cat $DIR/dead.txt | httprobe --prefer-https -c 200 >> $DIR/alive.txt

### Removing duplicates ###
sort -uo $DIR/alive.txt $DIR/alive.txt

### Removing alive subs from dead subs ###
sed -e 's/http:\/\///g' -e 's/https:\/\///g' -e 's/.*/\L&/' $DIR/alive.txt > $DIR/alive.tmp
grep -Fxvf $DIR/alive.tmp $DIR/dead.txt > $DIR/subs.tmp
mv $DIR/subs.tmp $DIR/dead.txt
rm $DIR/alive.tmp

### Calculate number of new subs found ###
echo -e "Number of new subdomains found:"
after=$(cat $DIR/alive.txt|wc -l)
let result=${after}-${before}
echo ${result}

### Display all the new subs ### 
echo -e "These are the new subdomains found:"
grep -F -x -v -f $DIR/alive.old $DIR/alive.txt
rm $DIR/alive.old
