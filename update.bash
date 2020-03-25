#!/usr/bin/env bash

source config.bash
source api.bash

update_msg() {
    echo "This server will go down for updating in $1!"
}

current_build="$(< "$current_version_file")"
latest_build="$(get_latest_build)"

# check if server is up to date
! (( latest_build > current_build )) && exit 0

echo "Server is out of date! Updating..."

if systemctl --user -q is-active "$service"; then
    echo "Stopping server in 5 minutes..."
    global_chat_message "$(update_msg "5 minutes")"
    sleep 4m
    global_chat_message "$(update_msg "1 minute")"
    sleep 30s
    global_chat_message "$(update_msg "30 seconds")"
    sleep 20s
    global_chat_message "$(update_msg "10 seconds")"
    sleep 7s
    global_chat_message "3..."
    sleep 1s
    global_chat_message "2..."
    sleep 1s
    global_chat_message "1..."
    sleep 1s
    global_chat_message "RIP"
    update_server true
else
    update_server false
fi

echo -n "$latest_build" > "$current_version_file"
