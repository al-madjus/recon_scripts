#!/bin/bash

DIR=$1

cat $DIR/scope/scope.txt | httprobe > $DIR/scope/alive.txt

sed -e 's/http:\/\///g' -e 's/https:\/\///g' -e 's/.*/\L&/' $DIR/scope/alive.txt > $DIR/scope/alive.tmp
grep -Fxvf $DIR/scope/alive.tmp $DIR/scope/scope.txt > $DIR/scope/dead.txt
rm $DIR/scope/alive.tmp
