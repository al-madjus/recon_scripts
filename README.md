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
- `domains.txt` if the target is a wildcard subdomain scope
- `scope.txt` including the defined (non-wildcard) scopes. This file will be automatically updated from `domains.txt`

## Usage

- `initial.sh` Used to set up the scope. 
- `tld.sh` Used for TLD wildcard scopes, like `*.mil`. 
