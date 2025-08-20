#!/bin/bash

# modified from: https://dev.to/mafflerbach/use-pass-and-rofi-to-get-a-fancy-password-manager-2k37

shopt -s nullglob globstar

# get all the saved password files
prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=( "$prefix"/**/*.gpg )
password_files=( "${password_files[@]#"$prefix"/}" )
password_files=( "${password_files[@]%.gpg}" )

# shows a list of all password files and saved the selected one in a variable
password=$(printf '%s\n' "${password_files[@]}" | wofi --dmenu "$@" --style=/home/gustav/.config/sway/wofi/style.css)
[[ -n $password ]] || exit


# pass -c copied the password in clipboard. The additional output from pass is piped in to /dev/null 
pass show -c "$password" | head -n1  2>/dev/null
