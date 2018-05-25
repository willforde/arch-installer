#!/usr/bin/env bash
set -e
set -u

cpToUsers()
{
    # Copy one file to every users home directory
    # arg1 = Source file to copy
    # arg2 = Path source will be copied to, path is relitive to user directory

    for user in $(cat /etc/passwd | grep "/home/" | grep -E "/bin/bash|/bin/zsh" | awk -F ":" '{print $1}'); do
        dest="/home/$user/$2"
        sudo install -vm 644 $1 ${dest}
        sudo chown ${user}:${user} ${dest}
    done
}

chkShell()
{
    cat /etc/passwd | grep $1 | awk -F ':' '{print $7}'
}