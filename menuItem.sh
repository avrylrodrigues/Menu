#!/bin/bash

# Function to see the date and time
show_dateandtime() {
    # Displays the system date and time
    dialog --infobox "Current date and time:\n `date`" 0 0
}

# Function to see the calendar
display_calendar() {
    # Displays the calendar and lets the user pick the date
    input_date=$(dialog --calendar "Select a date: " 0 0 2>&1 >/dev/tty)
    # Checks if the user selected anything
    if [ -n "$input_date" ]; then
        # Displays selected date
        dialog --infobox "Selected date: $input_date" 4 20
    else
        # If no date is selected
        dialog --infobox "No date selected." 3 25
    fi
}

# Function to delete selected file
delete_files() {
    # Asks user to input the desired directory
    dir_name=$(dialog --inputbox "Enter directory name (or leave blank for current directory):" 8 40 3>&1 1>&2 2>&3 3>&-)
    # Checks the input, if it’s blank it sets the current directory as the desired directory
    [ -z "$dir_name" ] && dir_name="."
    # Lists the name of the files in the directory and stores them in the array files
    files=($(ls "$dir_name"))
    # Goes through the files array to create a list of menu items consisting of an index and file name.
    menu_items=()
    for ((i = 0; i < ${#files[@]}; i++)); do
        menu_items+=("$i" "${files[i]}")
    done
    # Displays all the files so that the desired file can be deleted
    selected_index=$(dialog --menu "Select a file to delete:" 15 40 10 "${menu_items[@]}" 3>&1 1>&2 2>&3 3>&-)
    # Checks if anything was selected by the user
    if [ -n "$selected_index" ]; then
        selected_file="${files[selected_index]}"
        # Asks the user to confirm the deletion of the file
        dialog --yesno "Are you sure you want to delete $selected_file?" 8 40
        response=$?
        # Deletes the selected file
        if [ $response -eq 0 ]; then
            rm "$dir_name/$selected_file" && dialog --infobox "$selected_file deleted!" 6 40
        # If deletion of the file was cancelled
        else
            dialog --msgbox "Deletion canceled." 6 40
        fi
    # If no file was selected to be deleted
    else
        dialog --msgbox "No file selected." 6 40
    fi
}

# Function to exit the script
exit_menu() {
    # Displays a dialog box
    dialog --infobox "Exiting the script. Goodbye!" 3 40
    # Pauses execution for the specified time, in this case; 2 seconds
    sleep 2
    # Clears the terminal and exits the script
    clear
    exit 0
}

# Menu
while true; do
    # Displays the menu to the user allowing them to choose the option they want
    choice=$(dialog --menu "Choose an option: " 0 0 4 \
        1 "Show date and time" \
        2 "Show calendar" \
        3 "Delete file"\
        4 "Exit" 3>&1 1>&2 2>&3)
    # Checks the value of choice and does different operations based on its value
    case $choice in
        1) show_dateandtime ;;
        2) display_calendar ;;
        3) delete_files ;;
        4) exit_menu ;;
        # If users option doesn't match any option, an error message is displayed
        *) dialog --msgbox "Invalid selection." 0 0 ;;
    esac
done
