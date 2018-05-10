#!/usr/bin/env bash

source config.bash

login_route="/ServerAdmin/"
chat_route="/ServerAdmin/current/chat"

up_to_date_check() {
    curl -GLs "https://api.steampowered.com/ISteamApps/UpToDateCheck/v1/" \
        --data-urlencode "appid=$app_id" \
        --data-urlencode "version=$1" \
        | jq .response
}

# returns 0 on success, 1 on error
verify_login() {
    local redirect token login_response
    redirect="$(curl -Lsb "$cookie_jar" -c "$cookie_jar" -w "%{url_effective}" "$webadmin_url$login_route")"
    token="$(echo -n "$redirect" | sed '$d' | pup "input[name=\"token\"] attr{value}")"
    redirect="$(echo -n "$redirect" | tail -1)"
    [[ "$redirect" != *"$login_route" ]] && return 0

    login_response="$(curl -Lsb "$cookie_jar" -c "$cookie_jar" -X POST \
        --data-urlencode "username=$webadmin_username" \
        --data-urlencode "password=$webadmin_password" \
        --data-urlencode "remember=-1" \
        --data-urlencode "token=$token" \
        "$redirect")"
    [[ -z "$(echo -n "$login_response" | pup "div.message.error text{}")" ]] && return 0
    return 1
}

# returns 0 on success, 1 on error
chat_message() {
    local code
    verify_login || return
    code="$(curl -Lsb "$cookie_jar" -c "$cookie_jar" -o /dev/null -w "%{response_code}" -X POST \
        --data-urlencode "ajax=1" \
        --data-urlencode "message=$1" \
        --data-urlencode "teamsay=$2" \
        "$webadmin_url$chat_route")"
    [[ "$code" == "200" ]] && return 0
    return 1
}

# returns 0 on success, 1 on error
global_chat_message() {
    chat_message "$1" -1
}

# server is currently running <=> $1 = true
update_server() {
    $1 && systemctl --user stop "$service"
    eval "$steamcmd +login anonymous +app_update $app_id +exit"
    $1 && systemctl --user start "$service"
}
