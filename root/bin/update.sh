#!/bin/bash
command_list=(clear date echo eclean eix-sync eix-test-obsolete emerge eselect etc-update glsa-check logger revdep-rebuild tee unalias)
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

#date=$(/bin/date +%Y%m%d)
#time=$(/bin/date +%H%M)
script_directory_path="${0%/*}"
script_name="${0##*/}"
#log_directory_path="/var/log/custom/update"
# | /usr/bin/tee --append "${log_directory_path}/${date}-${time}-update"

/usr/bin/clear
/usr/bin/logger --tag "update" --id --stderr "${script_directory_path}/${script_name}: executed"

/bin/echo -e "\e[01;33mChecking for new updates...\e[0m"
/usr/bin/sudo --shell --user="${SUDO_USER}" /home/${SUDO_USER}/bin/gem update
/usr/bin/sudo --shell --user="${SUDO_USER}" /home/${SUDO_USER}/bin/pip-review --auto --user
/usr/bin/eix-sync
/usr/bin/emerge --ask --update --deep --newuse --tree --verbose @world
/usr/bin/flatpak update
/usr/sbin/etc-update
/usr/bin/emerge --ask --depclean --verbose
/usr/bin/glsa-check --test all
/usr/bin/glsa-check --list
/usr/bin/glsa-check --fix --quiet all
/usr/bin/revdep-rebuild --verbose -- --ask
/usr/bin/eclean --deep --time-limit="1m" distfiles
/usr/bin/eclean --deep --time-limit="1m" packages
/usr/bin/eix-test-obsolete
/usr/bin/eselect news read
