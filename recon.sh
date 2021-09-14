#!/bin/bash
# Set PATH here since cron has very limited PATH
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/snap/bin

#TODAY=$(date +%d%m%Y)

### Backup files
cat /root/targets/_results/nuclei-*.new >> /root/targets/_results/nuclei.old
rm /root/targets/_results/nuclei-*.new
cat /root/targets/_results/ffuf.new >> /root/targets/_results/ffuf.old
rm /root/targets/_results/ffuf.new
cat /root/targets/_results/subs.new >> /root/targets/_results/subs.old
cat /root/targets/_results/ports.new >> /root/targets/_results/ports.old
rm /root/targets/_results/subs.new
rm /root/targets/_results/ports.new

### Run recon ###
while read p; do /root/recon/recurrent.sh /root/targets/$p $1; done < /root/targets/programs.txt

### Run ffuf ###
while read p; do ffuf -u $p/FUZZ -w /usr/share/wordlists/default.txt -v -mc 200 -ac; done < /root/targets/_results/subs.new >> /root/targets/_results/ffuf.txt
cat /root/targets/_results/ffuf.txt | grep '| URL |' | cut -c 14- | tee -a /root/targets/_results/ffuf.new
rm /root/targets/_results/ffuf.txt

### Run nuclei with all templates ###
/usr/local/bin/nuclei --update-templates
/usr/local/bin/nuclei -l /root/targets/_results/subs.new -t /root/nuclei-templates/ -exclude helpers -exclude workflows -exclude exposed-tokens/generic -exclude miscellaneous/missing-csp.yaml -exclude miscellaneous/missing-hsts.yaml -exclude miscellaneous/missing-x-frame-options.yaml -exclude miscellaneous/robots.txt.yaml -exclude technologies -exclude dns/nameserver-detection.yaml -exclude miscellaneous/basic-cors-flash.yaml  -exclude miscellaneous/display-via-header.yaml -exclude vulnerabilities/generic/cors-misconfig.yaml -o -exclude miscellaneous/email-extractor.yaml -exclude miscellaneous/detect-options-method.yaml /root/targets/_results/nuclei.new

### Send email when finished ###
cat /root/targets/_results/nuclei*.new | grep '\[medium\]\|\[high\]\|\[critical\]' | mutt -s "Recon finished!" -- $1

### Send to git
cd ~/targets
git add .
git commit -m 'New recon data'
git push
