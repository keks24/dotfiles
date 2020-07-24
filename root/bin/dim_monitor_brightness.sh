#!/bin/bash
command_list=(logger sleep)
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

/usr/bin/logger --tag "dim monitor brightness" --id --stderr "${script_directory_path}/${script_name}: executed"

for brightness in {422..100..10}
do
    /bin/echo "${brightness}" > "/sys/class/backlight/intel_backlight/brightness"
    /bin/sleep 0.1
done
