#!/usr/bin/env bash

# a small, inefficient vdf key searcher

# usage: get_line_number match vdf_string
get_line_number() {
    local matches
    if ! matches="$(echo "$2" | grep -n "^$1$")"; then
        return 1
    fi
    echo "$matches" | head -1 | cut -f1 -d:
}

# usage: vdf_get_value vdf_string key_array
vdf_get_value() {
    local vdf=$1 keys ln_key ln_end vdf_new
    shift
    keys=("$@")

    if [[ "${#keys[@]}" == 1 ]]; then
        while read -r line; do
            if [[ "$line" =~ ^\"${keys[0]}\"[[:space:]]+\"(.*)\"$ ]]; then
                echo "${BASH_REMATCH[1]}"
                return 0
            fi
        done <<< "$vdf"
        return 1
    fi

    ! ln_key=$(get_line_number "\"${keys[0]}\"" "$vdf") && return 1

    vdf_new=$(echo "$vdf" | awk "NR>$ln_key")

    [[ $(echo "$vdf_new" | head -1) != "{" ]] && return 1

    ! ln_end=$(get_line_number "}" "$vdf_new") && return 1

    vdf_new=$(echo "$vdf_new" | awk "NR>1&&NR<$ln_end" | sed 's/^\t//g')

    vdf_get_value "$vdf_new" "${keys[@]:1}"
}
