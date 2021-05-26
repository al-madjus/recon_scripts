#!/bin/bash
DIR=$1/scope

### Find new subs using findomain and vita ###
findomain -f $DIR/domains.txt -q | tee -a $DIR/dead.txt $DIR/scope.txt
vita -f $DIR/domains.txt -a -t 3 | tee -a $DIR/dead.txt $DIR/scope.txt
chaos -dL $DIR/domains.txt -silent -filter-wildcard | tee -a $DIR/dead.txt $DIR/scope.txt

### Remove oos domains ###
while read p; do sed -i "/$p/d" $DIR/scope.txt; done < $DIR/oos.txt
while read p; do sed -i "/$p/d" $DIR/dead.txt; done < $DIR/oos.txt
sort -uo $DIR/dead.txt $DIR/dead.txt
sort -uo $DIR/scope.txt $DIR/scope.txt

### Find which subs are alive ### 
echo -e "Finding active subdomains on $1... "
cat $DIR/dead.txt | httprobe --prefer-https -c 400 >> $DIR/alive.txt

### Removing duplicates ###
sort -uo $DIR/alive.txt $DIR/alive.txt

### Removing alive subs from dead subs ###
sed -e 's/http:\/\///g' -e 's/https:\/\///g' -e 's/.*/\L&/' $DIR/alive.txt > $DIR/alive.tmp
grep -Fxvf $DIR/alive.tmp $DIR/dead.txt > $DIR/subs.tmp
mv $DIR/subs.tmp $DIR/dead.txt
rm $DIR/alive.tmp

### Clean up ###
rm $DIR/alive.tmp
