#!/bin/bash
# Set PATH here since cron has very limited PATH
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/loca/sbin

while read p; do ~/Pentesting/recon/recurrent.sh ~/Pentesting/targets/$p; done < ~/Pentesting/targets/programs.txt

### Do recon on the results from above ###
TODAY=$(date +%d%m%Y)

### Run ffuf ###
while read p; do ffuf -u $p/FUZZ -w /usr/share/wordlists/default.txt -v -mc 200 -ac; done < ~/Pentesting/targets/_results/subs-$TODAY.txt >> ~/Pentesting/targets/_results/ffuf.txt
cat ~/Pentesting/targets/_results/ffuf.txt | grep '| URL |' | cut -c 14- | tee -a ~/Pentesting/targets/_results/ffuf_$TODAY.txt
rm ~/Pentesting/targets/_results/ffuf.txt

### Run nuclei with all templates ###
nuclei -l ~/Pentesting/targets/_results/subs-$TODAY.txt -t ~/nuclei-templates/dns -t ~/nuclei-templates/generic-detections -t ~/nuclei-templates/panels -t ~/nuclei-templates/subdomain-takeovers -t ~/nuclei-templates/tokens -t ~/nuclei-templates/files -t ~/nuclei-templates/security-misconfiguration -t ~/nuclei-templates/technologies -t ~/nuclei-templates/vulnerabilities -o ~/Pentesting/targets/_results/nuclei-$TODAY.txt

### Send email when finished ###
cat ~/Pentesting/targets/_results/subs-$TODAY.txt | mutt -s "Recon finished!" -- $1
