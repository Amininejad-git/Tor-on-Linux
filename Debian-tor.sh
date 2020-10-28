#!/bin/bash


path_config="/home/amini/Projects/Tor-on-Linux/static.conf"

source "${path_config}" 2>/dev/null
echo "$HTML_FILE"

if [[ $? -ne 0 ]] ; then
    echo -e "\e[1;31m config file \e[1;32m${path_config} \e[1;31mnot exist"
    exit 1
fi

# requirements 
if [[ ! $(which feh) || ! $(which tor) || ! $(which proxychains4) || ! $(which obfs4proxy) ]]; then
    echo -e "check that programs are installed: "
    echo -e "proxychains \nfeh \ntor \nobfs4proxy${nc}"
    exit 1
fi

# delete tmp files
function ClearTmpFiles() {
    for file in "${HTML_FILE}" "${IMAGE_CAPTCHA_FILE}" "${BridgeFile}"; do
        if [[ -e "$file" ]]; then
            rm $file
        fi
    done
}

# get tor bridges from
function get_tor_bridges(){
    # get Captcha
    proxychains4 -q curl -s "$url_bridges" -o "$HTML_FILE"

    # net test
    [[ -z $(cat "$HTML_FILE" 2>/dev/null) ]] && echo "Error TOR" && exit 0

    # cut base64 Image challenge and convert to image
    base64 -i -d <<< $(egrep -o "\/9j\/[^\"]*" "$HTML_FILE") > $IMAGE_CAPTCHA_FILE

    # show image captcha security code
    feh "$IMAGE_CAPTCHA_FILE" &
    FEH_PID=$!

    # Captcha challenge field ( captcha serial )
    Cap_Serial=$(grep "value" "$HTML_FILE"|head -n 1 |cut -d\" -f 2)

    # captcha security code
    while [[ -z $captcha_security_code ]]; do
        # show your ip
        echo -ne "${light_magenta}[ $(proxychains4 -q curl -s "$IpSite") ] ${light_blue}"

        # get code from user
        read -p "enter code (enter 'r' for reset captcha): " captcha_security_code

        # press 'r' for reset captcha
        if [[ $captcha_security_code == "r" ]]; then
            # close image captcha security code
            kill $FEH_PID

            # delete tmp files
            ClearTmpFiles

            # unset captcha_security_code
            unset captcha_security_code

            # reset captcha
            get_tor_bridges

            return
        fi

        # slove captcha and get Bridges
        proxychains4 -q curl -s "$url_bridges" \
        --data "captcha_challenge_field=${Cap_Serial}&captcha_response_field=${captcha_security_code}&submit=submit" -o "$BridgeFile"

        # cut bridges from html file(if code is incorrect bridges file is empty)
        RES=$(grep "^obfs4" "$BridgeFile"|egrep -o "^[^<]*")

        # if captcha_security_code is correct code save bridges into Variable BRIDGES
        # if incorrect print error
        if [[ $(tr -d '\n' <<< "$RES") ]]; then
            BRIDGES="$(sed 's/^/Bridge /g' <<< "$RES")"
        else
            echo -e "${light_yellow}the code entered is incorrect! try again ..${nc}"
            # for continue while and try again . unset captcha_security_code
            unset captcha_security_code
        fi
    done

    # close image captcha security code
    kill $FEH_PID
}

get_tor_bridges
#systemctl reload tor

