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
    last_cmd=$(last -a | grep "pts\|tty" | tac | uniq -u)

    while read -r line; do
        c_host=$(echo "$line" | awk '{print $NF}')

        # Compute something based on the 6th field (e.g., append "_processed" to the 6th field)
        c_host_geoip_json=$(curl -s https://json.geoiplookup.io/${c_host})
        
        c_host_geoip=$(echo $c_host_geoip_json | jq -r '.country_name')

        if [[ "$c_host_geoip" == "null" ]]; then
            c_host_geoip="No host"
        fi
        
        # Append the modified line to the final_output variable
        last_cmd_geoip+="${line} ${c_host_geoip}\n"
    done <<< "$last_cmd"

    dialog --clear --backtitle "Last logins" --title \
        "Last logins" --msgbox "$last_cmd_geoip" 10 100
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
