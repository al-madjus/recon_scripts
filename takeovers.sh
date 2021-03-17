#!/bin/bash

# Loop through all programs
for d in /root/targets/*; do
	# Get program name
	PROGRAM=`echo $d | cut -c 15-`
	# Get new list of subs, removing known takeovers
	if [ -f "$d/scope/knowntakeovers.txt" ]
	then
	#	diff $d/scope/knowntakeovers.txt $d/scope/alive.txt | grep "^>" | cut -c3- >> $d/scope/all.txt
	grep -Fxvf $d/scope/knowntakeovers.txt $d/scope/alive.txt >> $d/scope/all.txt
	else
		cp $d/scope/alive.txt $d/scope/all.txt
	fi

	# Run nuclei takeover script on subs
	/usr/local/bin/nuclei -l $d/scope/all.txt -t /root/nuclei-templates/takeovers/ -o /root/targets/_results/nuclei-takeover-$PROGRAM.txt
	if [ -f "/root/targets/_results/nuclei-takeover-$PROGRAM.txt" ] 
	then
        	if [ -s "/root/targets/_results/nuclei-takeover-$PROGRAM.txt" ] 
		then
			# Send email with results
                	cat /root/targets/_results/nuclei-takeover-$PROGRAM.txt | mutt -s "[!] Possible subdomain takeover on $PROGRAM" -- $1
		else
			# Clean up empty file
			rm /root/targets/_results/nuclei-takeover-$PROGRAM.txt
		fi
	fi
	# Clean up
	rm $d/scope/all.txt
done
