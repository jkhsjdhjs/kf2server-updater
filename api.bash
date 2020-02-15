#!/usr/bin/env bash

source config.bash
source vdf.bash

login_route="/ServerAdmin/"
chat_route="/ServerAdmin/current/chat"

get_latest_build() {
    local vdf keys
    vdf="$("$steamcmd" +login anonymous +app_info_update 1 +app_info_print "$app_id" +quit | sed "1,/^AppID : $app_id/d")"
    keys=("$app_id" depots branches public buildid)
    vdf_get_value "$vdf" "${keys[@]}"
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
    "$steamcmd" +login anonymous +app_update $app_id +exit
    $1 && systemctl --user start "$service"
}
