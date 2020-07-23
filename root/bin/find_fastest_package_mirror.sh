#!/bin/bash
command_list=(dirname echo mirrorselect unalias)
checkCommands()
{
    for current_command in "${command_list[@]}"
    do
        unalias ${current_command} 2>/dev/null
        if [[ ! $(command -v ${current_command} 2>/dev/null) ]]
        then
            /bin/echo -e "\e[01;31mCould not find command '${current_command}'.\e[0m"
            exit 1
        fi
    done
}

checkCommands

script_directory_path="${0%/*}"
script_name="${0##*/}"

/usr/bin/logger --tag "find_fastest_package_mirror" --id --stderr "${script_directory_path}/${script_name}: executed"
/usr/bin/mirrorselect --deep --servers 3 --blocksize 10 --output > "${script_directory_path}/configs/fastest_gentoo_make.conf"
/usr/bin/mirrorselect --deep --rsync --all --blocksize 10 --output > "${script_directory_path}/configs/fastest_rsync_repos.conf"
