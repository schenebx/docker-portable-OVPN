#!/bin/sh
# 2FA setup OVPN server will pass user/pass by file to this script
passfile=$1

# Get the user/pass from the tmp file
user=$(head -1 $passfile)
pass=$(tail -1 $passfile) 

# in oauth.secrets, <username>:<secret>
# Find the first match of <username>, ignore case, then extract the <secret>
secret=$(grep -i -m 1 "$user:" oauth.secrets | cut -d: -f2)

# Calculate the expected 2FA code
code=$(oathtool --totp $secret)

if [ "$code" = "$pass" ];
then
	exit 0
fi
