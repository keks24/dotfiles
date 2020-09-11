#!/bin/bash
command_list=(b2sum chmod clear date find logger mount mountpoint rsync sleep tee touch)
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

# define global variables
script_directory_path="${0%/*}"
script_name="${0##*/}"
declare -a source_directory_list
source_directory_list=("/home" "/media/animes")
countdown_seconds="5"
current_iso_date=$(/bin/date +%Y%m%d)
current_time=$(/bin/date +%H%M%S)
log_directory="./logs"
log_filename="${current_iso_date}-${current_time}_${script_name}.log"
log_file="${log_directory}/${log_filename}"
# do not use "${script_directory_path}" here. when executed manually, the variable will expand to "create_backup.sh"!
backup_directory="./backup"
checksum_filename="checksums.b2"

calculateChecksums()
{
    pushd "${backup_directory}" >/dev/null
    /usr/bin/find . -type f -not -name "${checksum_filename}" -exec /usr/bin/b2sum "{}" + > "${checksum_filename}"
    popd >/dev/null
}

checkAndMountPartitions()
{
    for source_directory in ${source_directory_list[@]}
    do
        /bin/mountpoint --quiet "${source_directory}"
        local return_code="${?}"

        if [[ "${return_code}" != "0" ]]
        then
            /bin/echo -e "\e[01;33mmounted ${source_directory}.\e[0m"
            /bin/mount "${source_directory}"
            unset return_code
        fi
    done
}

correctPermissions()
{
    /bin/chmod 640 "${log_file}"
}

countDown()
{
    local current_countdown_seconds="${countdown_seconds}"

    /bin/echo -ne "\e[01;31mexecuting backup in ... \e[0m"
    while (( "${current_countdown_seconds}" > 0 ))
    do
        /bin/echo -ne "\e[01;31m${current_countdown_seconds} \e[0m"
        /bin/sleep 1
        (( current_countdown_seconds-- ))
    done
    /bin/echo ""
}

createSystemLogEntry()
{
    /usr/bin/logger --tag "manual backup" --id --stderr "${script_directory_path}/${script_name}: executed"
}

createLogFile()
{
    /bin/touch "${log_file}"

    correctPermissions
}

executeBackup()
{
    /usr/bin/rsync --delete --archive --hard-links --acls --xattrs --relative --info="progress2" --verbose "${source_directory_list[@]}" "${backup_directory}" |  /usr/bin/tee "${log_file}"
}

main()
{
    /usr/bin/clear

    checkAndMountPartitions

    countDown

    createSystemLogEntry

    createLogFile

    executeBackup

    calculateChecksums
}

main
