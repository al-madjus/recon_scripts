#!/bin/bash
# Set PATH here since cron has very limited PATH
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

#TODAY=$(date +%d%m%Y)

### Backup files
cat /home/al-madjus/Pentesting/targets/_results/nuclei-*.new >> /home/al-madjus/Pentesting/targets/_results/nuclei.old
rm /home/al-madjus/Pentesting/targets/_results/nuclei-*.new
cat /home/al-madjus/Pentesting/targets/_results/ffuf.new >> /home/al-madjus/Pentesting/targets/_results/ffuf.old
rm /home/al-madjus/Pentesting/targets/_results/ffuf.new
cat /home/al-madjus/Pentesting/targets/_results/subs.new >> /home/al-madjus/Pentesting/targets/_results/subs.old
cat /home/al-madjus/Pentesting/targets/_results/ports.new >> /home/al-madjus/Pentesting/targets/_results/ports.old
rm /home/al-madjus/Pentesting/targets/_results/subs.new
rm /home/al-madjus/Pentesting/targets/_results/ports.new

### Run recon ###
while read p; do /home/al-madjus/Pentesting/recon/recurrent.sh /home/al-madjus/Pentesting/targets/$p; done < /home/al-madjus/Pentesting/targets/programs.txt

### Run ffuf ###
while read p; do ffuf -u $p/FUZZ -w /usr/share/wordlists/default.txt -v -mc 200 -ac; done < /home/al-madjus/Pentesting/targets/_results/subs.new >> /home/al-madjus/Pentesting/targets/_results/ffuf.txt
cat /home/al-madjus/Pentesting/targets/_results/ffuf.txt | grep '| URL |' | cut -c 14- | tee -a /home/al-madjus/Pentesting/targets/_results/ffuf.new
rm /home/al-madjus/Pentesting/targets/_results/ffuf.txt

### Run nuclei with all templates ###
/usr/local/bin/nuclei --update-templates
while read p; do /usr/local/bin/nuclei -l /home/al-madjus/Pentesting/targets/_results/subs.new -t /home/al-madjus/nuclei-templates/$p -o /home/al-madjus/Pentesting/targets/_results/nuclei-$p.new; done < /home/al-madjus/Pentesting/recon/templates.txt

### Send email when finished ###
cat /home/al-madjus/Pentesting/targets/_results/subs.new | mutt -s "Recon finished!" -- $1
