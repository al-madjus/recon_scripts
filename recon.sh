#!/bin/bash
# Set PATH here since cron has very limited PATH
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

while read p; do /home/al-madjus/Pentesting/recon/recurrent.sh /home/al-madjus/Pentesting/targets/$p; done < /home/al-madjus/Pentesting/targets/programs.txt

### Do recon on the results from above ###
TODAY=$(date +%d%m%Y)

### Run ffuf ###
while read p; do ffuf -u $p/FUZZ -w /usr/share/wordlists/default.txt -v -mc 200 -ac; done < /home/al-madjus/Pentesting/targets/_results/subs-$TODAY.txt >> /home/al-madjus/Pentesting/targets/_results/ffuf.txt
cat /home/al-madjus/Pentesting/targets/_results/ffuf.txt | grep '| URL |' | cut -c 14- | tee -a /home/al-madjus/Pentesting/targets/_results/ffuf_$TODAY.txt
rm /home/al-madjus/Pentesting/targets/_results/ffuf.txt

### Run nuclei with all templates ###
nuclei --update-templates
nuclei -l /home/al-madjus/Pentesting/targets/_results/subs-$TODAY.txt -t /home/al-madjus/nuclei-templates/dns -o /home/al-madjus/Pentesting/targets/_results/nuclei-dns-$TODAY.txt
nuclei -l /home/al-madjus/Pentesting/targets/_results/subs-$TODAY.txt -t /home/al-madjus/nuclei-templates/generic-detections -o /home/al-madjus/Pentesting/targets/_results/nuclei-generic-$TODAY.txt
nuclei -l /home/al-madjus/Pentesting/targets/_results/subs-$TODAY.txt -t /home/al-madjus/nuclei-templates/panels -o /home/al-madjus/Pentesting/targets/_results/nuclei-panels-$TODAY.txt
nuclei -l /home/al-madjus/Pentesting/targets/_results/subs-$TODAY.txt -t /home/al-madjus/nuclei-templates/subdomain-takeovers -o /home/al-madjus/Pentesting/targets/_results/nuclei-takeovers-$TODAY.txt
nuclei -l /home/al-madjus/Pentesting/targets/_results/subs-$TODAY.txt -t /home/al-madjus/nuclei-templates/tokens -o /home/al-madjus/Pentesting/targets/_results/nuclei-tokens-$TODAY.txt
nuclei -l /home/al-madjus/Pentesting/targets/_results/subs-$TODAY.txt -t /home/al-madjus/nuclei-templates/files -o /home/al-madjus/Pentesting/targets/_results/nuclei-files-$TODAY.txt
nuclei -l /home/al-madjus/Pentesting/targets/_results/subs-$TODAY.txt -t /home/al-madjus/nuclei-templates/security-misconfiguration -o /home/al-madjus/Pentesting/targets/_results/nuclei-misconf-$TODAY.txt
nuclei -l /home/al-madjus/Pentesting/targets/_results/subs-$TODAY.txt -t /home/al-madjus/nuclei-templates/technologies -o /home/al-madjus/Pentesting/targets/_results/nuclei-tech-$TODAY.txt
nuclei -l /home/al-madjus/Pentesting/targets/_results/subs-$TODAY.txt -t /home/al-madjus/nuclei-templates/vulnerabilities -o /home/al-madjus/Pentesting/targets/_results/nuclei-vulns-$TODAY.txt

### Send email when finished ###
cat /home/al-madjus/Pentesting/targets/_results/subs-$TODAY.txt | mutt -s "Recon finished!" -- $1
