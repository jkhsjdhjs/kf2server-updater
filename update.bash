#!/usr/bin/env bash

source config.bash
source api.bash

update_msg() {
    echo "This server will go down for updating in $1!"
}

response="$(up_to_date_check "$(cat "$current_version_file")")"

[[ "$(echo "$response" | jq .success)" != "true" ]] && exit 1
[[ "$(echo "$response" | jq .up_to_date)" == "true" ]] && exit 0

if systemctl --user -q is-active "$service"; then
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

echo "$response" | jq .required_version > "$current_version_file"
