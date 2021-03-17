#!/bin/bash
# Automated recurrent recon

DIR=$1/scope
TODAY=$(date +%d%m%Y)
PROGRAM=$(cut -c 15- <<<$1)

### Check how many subs we already had ###
before=$(cat $DIR/alive.txt|wc -l)

### Backup files ###
cp $DIR/alive.txt $DIR/alive.old

### Find new subs using findomain and vita ###
findomain -f $DIR/domains.txt -q | tee -a $DIR/dead.txt $DIR/scope.txt
vita -f $DIR/domains.txt -a -t 3 | tee -a $DIR/dead.txt $DIR/scope.txt
while read p; do github-subdomains -d $p -raw | grep -v 'token not found' | grep -v '^$' | tee -a $DIR/dead.txt $DIR/scope.txt; done <$DIR/domains.txt
while read p; do sublist3r.py -d $p -b -o $DIR/sublist3r.txt & cat $DIR/sublist3r.txt >> $DIR/scope.txt & cat $DIR/sublist3r.txt >> $DIR/dead.txt; done <$DIR/domains.txt
# clean up sublist3r
killall python3
# chaos client
chaos -dL $DIR/domains.txt -silent -filter-wildcard | tee -a $DIR/dead.txt $DIR/scope.txt

### Create program specific wordlist ###
#cat $DIR/scope.txt | awk -F "." '{print $(NF-2)}' | sort -u >> $DIR/wordlist.txt
#sort -uo $DIR/wordlist.txt $DIR/wordlist.txt
### Run syborg with above generated wordlist ###
#while read p; do syborg.py $p -w $DIR/wordlist.txt -o $DIR/syborg.txt & cat $DIR/syborg.txt >> $DIR/dead.txt & cat $DIR/syborg.txt >> $DIR/scope.txt; done <$DIR/domains.txt
### Remove syborg files ###
#rm ./*.queue

### Remove all oos domains from comcast scope ###
if grep -q 'comcast' <<<$DIR; then
	sed -i '/hsd1/d' $DIR/scope.txt $DIR/dead.txt
fi

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

### Calculate number of new subs found ###
echo -e "Number of new subdomains found:"
after=$(cat $DIR/alive.txt|wc -l)
let result=${after}-${before}
echo ${result}

### Display all the new subs ### 
echo "### $PROGRAM ###" >> $DIR/../../_results/subs.new
echo -e "These are the new subdomains found:"
grep -F -x -v -f $DIR/alive.old $DIR/alive.txt | tee -a $DIR/../../_results/subs.new $DIR/newsubs.tmp
rm $DIR/alive.old
rm $DIR/newsubs.tmp

### Check for takeovers ###
#/usr/local/bin/nuclei -l $DIR/alive.txt -t /root/nuclei-templates/takeovers/ -o /root/targets/_results/nuclei-takeover-$PROGRAM.txt
#if [ -f "/root/targets/_results/nuclei-takeover-$PROGRAM.txt" ] 
#then
#	if [ -s "/root/targets/_results/nuclei-takeover-$PROGRAM.txt" ] 
#	then
#		cat /root/targets/_results/nuclei-takeover-$PROGRAM.txt | mutt -s '[!] Possible subdomain takeover' -- $2
#	else 
#		rm /root/targets/_results/nuclei-takeover-$PROGRAM.txt
#	fi
#fi

### Remove http:// and https:// from the temporary file ###
sed -e 's/http:\/\///g' -e 's/https:\/\///g' -e 's/.*/\L&/' $DIR/alive.txt > $DIR/alive.tmp

### Run zdns on above file ###
zdns A --name-servers=1.1.1.1 -input-file $DIR/alive.tmp -output-file $DIR/ip_hosts.txt

### Filter out IP address from the IP list ###
cat $DIR/ip_hosts.txt | jq '.data.answers' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort -u > $DIR/ip.txt

### Save old masscan output ### 
mv $DIR/masscan.txt $DIR/masscan.old

### Run masscan ###
sudo masscan -iL $DIR/ip.txt -p0-79,81-442,444-1000,1001,1008,1019,1021-1034,1036,1038-1039,1041,1043-1045,1049,1068,1419,1433-1434,1522,1645-1646,1701,1718-1719,1782,1812-1813,1885,1900,2000,2002,2048-2049,2148,2222-2223,2967,3000-3001,3052,3130,3283,3306,3389,3456,3659,3703,4000,4045,4443-4444,4500,4672,5000-5001,5060-5061,5093,5351,5353,5355,5432,5500,5632,5900,6000-6001,6346,7938,8000,9000-9001,9200,9876,10000,10080,11487,16680,17185,19283,19682,20031,22986,27892,30718,31337,32768-32773,32815,33281,33354,34555,34861-34862,37444,39213,41524,44968,49152-49154,49156,49158-49159,49162-49163,49165-49166,49168,49171-49172,49179-49182,49184-49196,49199-49202,49205,49208-49211,58002,65024 --rate 1000 -oG $DIR/masscan.txt

### Display new ports ### 
echo "New ports for $1: " >> $DIR/../../_results/ports.new
grep -Fxvf $DIR/masscan.old $DIR/masscan.txt | tee -a $DIR/../../_results/ports.new

### Clean up ###
#rm $DIR/syborg.txt
rm $DIR/sublist3r.txt
rm $DIR/alive.tmp
rm $DIR/ip.txt
rm $DIR/masscan.old
while read p; do rm ~/$p.txt ~/$p.old.txt; done < $DIR/domains.txt
