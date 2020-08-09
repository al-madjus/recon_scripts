#!/bin/bash
while read p; do ~/recon/recurrent-recon.sh ~/targets/$p; done < ~/programs.txt
