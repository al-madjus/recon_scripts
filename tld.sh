#!/bin/bash

DIR=~/targets/$2/scope

# Run crtsh.sh
crtsh.sh $1 >> $DIR/crtsh.txt

# Grep domain names
cat $DIR/crtsh.txt | awk -F "." '{print $(NF-2)"."$(NF-1)"."$NF}' > $DIR/domains.txt

# Remove duplicates
sort -uo $DIR/domains.txt $DIR/domains.txt
