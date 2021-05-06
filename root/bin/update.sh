#!/bin/bash
#############################################################################
# Copyright 2020 Ramon Fischer                                              #
#                                                                           #
# Licensed under the Apache License, Version 2.0 (the "License");           #
# you may not use this file except in compliance with the License.          #
# You may obtain a copy of the License at                                   #
#                                                                           #
#     http://www.apache.org/licenses/LICENSE-2.0                            #
#                                                                           #
# Unless required by applicable law or agreed to in writing, software       #
# distributed under the License is distributed on an "AS IS" BASIS,         #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  #
# See the License for the specific language governing permissions and       #
# limitations under the License.                                            #
#############################################################################

command_list=(clear date echo eclean eix eix-sync eix-test-obsolete emerge eselect etc-update glsa-check logger revdep-rebuild tee unalias)
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
/usr/bin/sudo --shell --user="${SUDO_USER}" /home/${SUDO_USER}/bin/pip-review --auto --user --no-warn-script-location
/usr/bin/sudo --shell --user="${SUDO_USER}" /home/${SUDO_USER}/bin/pip check
/usr/bin/sudo --shell --user="${SUDO_USER}" /usr/bin/flatpak update
/usr/bin/eix-sync

if /usr/bin/eix --upgrade sys-apps/portage >/dev/null
then
    /bin/echo -e "\e[01;31mA new version of 'sys-apps/portage' was found. Updating it first...\e[0m"
    /usr/bin/emerge --ask --oneshot sys-apps/portage
fi

/usr/bin/emerge --ask --update --deep --newuse --tree --verbose @world
/usr/sbin/etc-update
/usr/bin/emerge --ask --depclean --verbose
/usr/bin/glsa-check --test all
/usr/bin/glsa-check --list
/usr/bin/glsa-check --fix --quiet all
/usr/bin/revdep-rebuild --verbose -- --ask
/usr/bin/eclean --deep --time-limit="1m" distfiles
/usr/bin/eclean --deep --time-limit="1m" packages
/usr/bin/eix-test-obsolete
/usr/bin/elogv
/usr/bin/eselect news read
