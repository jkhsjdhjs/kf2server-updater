#!/usr/bin/env bash

source config.bash
source api.bash

check_dependency() {
    command -v "$1" >/dev/null 2>&1 || {
        echo >&2 "Error: $1 is required"
        exit 1
    }
}

check_dependency pup
check_dependency jq

if [[ -z ${XDG_RUNTIME_DIR+x} ]]; then
    XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export XDG_RUNTIME_DIR
fi

systemd_user_units_path="$HOME/.config/systemd/user"

mkdir -p "$systemd_user_units_path"
cp systemd-units/{kf2server.service,kf2server-update.{timer,service}} "$systemd_user_units_path"
systemctl --user daemon-reload
systemctl --user enable --now kf2server.service kf2server-update.timer
up_to_date_check 0 | jq .required_version > "$current_version_file"
