#!/bin/bash
# parse the oauth.secrets, which is in <username>:<secret> format, to png.
# Usage: ./<this>.sh oauth.secrets

# loop all lines, ignore empty lines or # commented lines
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ ! $line =~ ^\# ]] && [[ ! -z $line ]]; then
        username=$(echo $line | cut -d ':' -f 1)
        secret=$(echo $line | cut -d ':' -f 2-)
        # the Base32 str
        B32Str=$(oathtool --totp -v $secret | grep -i "Base32 secret:" | cut -d ":" -f 2- | xargs)
        usernameEncoded=$(node -e "console.log(encodeURIComponent(\"$username\"))")
        [[ -z $usernameEncoded ]] && echo "ERROR: encoded username is empty." && exit 1
        oauthStr="otpauth://totp/${usernameEncoded}?secret=${B32Str}&algorithm=SHA256&digits=6&period=30"
        python3 ./2FA_secret_to_img_helper.py $username $oauthStr
    fi
done < $1

