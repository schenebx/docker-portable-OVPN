#!/bin/bash
# Generate the oauth 2FA secrets, save to the file $2 in <username>:<secret> format
# Usage: ./<this>.sh <howManyClientsToGenerate> <dstSecretsFile>

# $1: number of clients needed
# $2: /path/to/oauth.secrets

[[ -z $1 || -z $2 ]] && echo "ERROR. Insufficient param for $0" && exit 1

for i in $(seq $1)
do
    DIGEST=$(head /dev/urandom -c 100 | sha256sum | cut -d ' ' -f 1)
    echo client$i:$DIGEST >> $2
done
    