#!/bin/bash

# Unique design
echo -e "\n"
echo "====================================================="
echo "Welcome to Automatic Upgrade"
echo -n "We will upgrade your system "

# Get the Linux distribution
if [ -x "$(command -v lsb_release)" ]; then
    distro=$(lsb_release -is)
    echo "($distro) automatically."
else
    echo "(Unknown distribution) automatically."
fi

echo "====================================================="
echo -e "\n"
echo "Code written by:"
echo "'##::::'##::::'###::::'########:::'######::'##::::'##:"
echo " ##:::: ##:::'## ##::: ##.... ##:'##... ##: ##:::: ##:"
echo " ##:::: ##::'##:. ##:: ##:::: ##: ##:::..:: ##:::: ##:"
echo " #########:'##:::. ##: ########::. ######:: #########:"
echo " ##.... ##: #########: ##.. ##::::..... ##: ##.... ##:"
echo " ##:::: ##: ##.... ##: ##::. ##::'##::: ##: ##:::: ##:"
echo " ##:::: ##: ##:::: ##: ##:::. ##:. ######:: ##:::: ##:"
echo "..:::::..::..:::::..::..:::::..:::......:::..:::::..::"
echo -e "\n"

# Function to display progress bar
function progress_bar() {
    local duration=${1}
    local progress_char="▓"
    local total_steps=${2}
    local step=${3}
    local percentage=$((step * 100 / total_steps))
    local columns=$(tput cols)
    local clear_line="\r\033[K"
    local total_columns=$((columns - 10))
    local num_chars=$((percentage * total_columns / 100))

    printf "${clear_line}["
    for ((i=0; i<num_chars; i++)); do printf "$progress_char"; done
    for ((i=num_chars; i<total_columns; i++)); do printf " "; done
    printf "] $percentage%%"
    printf "\n"
}

# Total steps in the update process
total_steps=6

# Function to run command and update progress
function run_command() {
    local command=$1
    local log_file=$2
    local step=$3
    echo "Running $command..."
    $command 2>&1 | tee $log_file
    # Update progress
    progress_bar $step $total_steps $step
}

# Update package lists
run_command "sudo apt update" "update.log" 1

# Check if upgrade is needed
if [ -f "update.log" ] && grep -q 'package[s]\? can be upgraded' update.log; then
    run_command "sudo apt upgrade -y" "upgrade.log" 2
fi

# Check if fix broken dependencies is needed
if [ -f "upgrade.log" ] && grep -q 'Unmet dependencies' upgrade.log; then
    run_command "sudo apt --fix-broken install -y" "fix_broken.log" 3
fi

# Check if autoremove is needed
if [ -f "fix_broken.log" ] && grep -q 'The following package[s]\? will be REMOVED' fix_broken.log; then
    run_command "sudo apt autoremove -y" "autoremove.log" 4
fi

# Check for any further upgrades
run_command "sudo apt upgrade -y" "further_upgrade.log" 5

# Clean up cached packages
run_command "sudo apt clean" "clean.log" 6

echo "Update complete."
