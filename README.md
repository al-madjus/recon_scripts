# recon_scripts
Recon scripts for bug hunting

## Installation

First install the required tools: 

- ffuf
- findomain
- httprobe
- jq
- masscan
- nuclei
- vita
- zdns
- github-subdomains

## Setup

The recon scripts require a folder for each target with a subfolder called `scope` including the following files: 
- `domains.txt` if the target is a wildcard subdomain scope. 
- `scope.txt` including the defined (non-wildcard) scopes. This file will be automatically updated from `domains.txt`. 
- `oos.txt` holds out-of-scope domains. Does not support wildcards. 

In the main folder which holds all the targets, define `programs.txt` which includes the targets to scan. The target name should be the same as the folder name for that target. 

You'll also find `templates.txt` in the recon folder, this specifies the templates nuclei will run. 

## Usage

- `initial.sh /pathtotargets/target` Used to set up the scope. This will create `alive.txt` for the alive subdomains and dead.txt for the dead subdomains. 
- `tld.sh TLD /pathtotargets/target` Used for TLD wildcard scopes, like `*.mil`. The script will populate `domains.txt` with all unique domains found for the specified TLD. 
- `recon.sh notification@email.com` This is the main script that calls `recurrent.sh` on each target and finally runs `ffuf` and `nuclei` on the results. 
- `create_scope.txt` - Obsolete, will probably be removed. 
