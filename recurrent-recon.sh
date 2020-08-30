#!/bin/bash
# Automated recurrent recon

DIR=$1/scope
TODAY=`date +"%d%m%Y"`

### Check how many subs we already had ###
before=$(cat $DIR/alive.txt|wc -l)

### Backup alive subs ###
cp $DIR/alive.txt $DIR/alive.old

### Find which subs are alive ### 
echo -e "Finding active subdomains on $1... "
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
echo "### $1 ###" >> ~/_results/subs-$TODAY.txt
echo -e "These are the new subdomains found:"
#echo "New subdomains: " >> ~/output-$TODAY.txt
grep -F -x -v -f $DIR/alive.old $DIR/alive.txt | tee -a ~/_results/subs-$TODAY.txt
rm $DIR/alive.old

### Remove http:// and https:// from the newest file ###
sed -e 's/http:\/\///g' -e 's/https:\/\///g' -e 's/.*/\L&/' $DIR/alive.txt > $DIR/alive.tmp

### Run zdns on above file ###
zdns A --name-servers=1.1.1.1 -input-file $DIR/alive.tmp -output-file $DIR/ip_hosts.txt

### Filter out IP address from the IP list ###
cat $DIR/ip_hosts.txt | jq '.data.answers' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort -u > $DIR/ip.txt

### Save old masscan output ### 
mv $DIR/masscan.txt $DIR/masscan.old

### Run masscan ###
sudo masscan -iL $DIR/ip.txt -p0-1000,1001,1008,1019,1021-1034,1036,1038-1039,1041,1043-1045,1049,1068,1419,1433-1434,1522,1645-1646,1701,1718-1719,1782,1812-1813,1885,1900,2000,2002,2048-2049,2148,2222-2223,2967,3000-3001,3052,3130,3283,3306,3389,3456,3659,3703,4000,4045,4443-4444,4500,4672,5000-5001,5060-5061,5093,5351,5353,5355,5432,5500,5632,5900,6000-6001,6346,7938,8000,8080,9000-9001,9200,9876,10000,10080,11487,16680,17185,19283,19682,20031,22986,27892,30718,31337,32768-32773,32815,33281,33354,34555,34861-34862,37444,39213,41524,44968,49152-49154,49156,49158-49159,49162-49163,49165-49166,49168,49171-49172,49179-49182,49184-49196,49199-49202,49205,49208-49211,58002,65024 --rate 1000 -oG $DIR/masscan.txt

### Display new ports ### 
echo "New ports: " >> ~/_results/ports-$TODAY.txt
grep -Fxvf $DIR/masscan.old $DIR/masscan.txt | tee -a ~/_results/ports-$TODAY.txt

### Clean up ###
rm $DIR/alive.tmp
rm $DIR/ip.txt
rm $DIR/masscan.old
