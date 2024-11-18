#!/bin/bash

# Function to display the main menu
show_main_menu() {
    dialog --clear --backtitle "Have I Been Hacked?" --title "HIBH v. 0.1" \
        --menu "Choose an option:" 15 50 4 \
        1 "Show last logins" \
        2 "BlaBlaBla" \
        3 "Exit" 2>"$tempfile"
    menu_choice=$(<"$tempfile")

    case $menu_choice in
        1) show_last_logins ;;
        2) show_last_logins ;;
        3) exit_app ;;
    esac
}

# Function to display last logins
show_last_logins() {
    last_cmd=$(last -a | grep "pts\|tty" | uniq -u)

    while read -r line; do
        # Extract 'last' command final column (hostname)
        c_host=$(echo "$line" | awk '{print $NF}')
        
        # Obtain IP Geo data from geoiplookup.io based on c_host value 
        c_host_geoip_json=$(curl -s https://json.geoiplookup.io/${c_host})
        
        c_host_country=$(echo $c_host_geoip_json | jq -r '.country_name'),
        c_host_city=$(echo $c_host_geoip_json | jq -r '.city')

        if [[ "$c_host_country" == "null" ]]; then
            c_host_country="No host"
            c_host_city=""
        fi
        
        # Append the modified line to the final_output variable
        last_cmd_geoip+="${line} ${c_host_country} ${c_host_city}\n"
    done <<< "$last_cmd"

    dialog --clear --backtitle "Last logins" --title \
        "Last logins" --msgbox "$last_cmd_geoip" 30 100
    show_main_menu
}

# Function to exit the app
exit_app() {
    dialog --clear --backtitle "Exit" --title "Goodbye" \
        --msgbox "Thank you for using this app!" 10 50
    clear
    exit
}

# Main script execution starts here
tempfile=$(mktemp)

trap "rm -f $tempfile" EXIT
show_main_menu
