#!/bin/bash
#############################################################################
# Copyright 2020-2022 Ramon Fischer                                         #
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

command_list=("/bin/cat" "/usr/bin/find" "/bin/rm" "/usr/bin/sort")
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

# define global directories
declare -a music_directory_array
declare -a existing_playlist_filename_array
music_directory_array=("../normal_music" "../unusual_music")
music_filename_suffix="aac"
playlist_filename_suffix="m3u8"
playlist_all_filename="all.${playlist_filename_suffix}"
existing_playlist_filename_array=("./all.m3u8" "./normal_music.m3u8" "./unusual_music.m3u8")

checkAndPromptExistingPlaylists()
{
    if [[ "${existing_playlist_filename_array[@]}" != "" ]]
    then
        local remove_playlist_files
        read -p $'\e[01;31mFound existing playlists in this directory. Remove them before generating new playlists? (Y/n): \e[0m' remove_playlist_files

        case "${remove_playlist_files:-y}" in
            "y"|"Y")
                /bin/rm --force --verbose "${existing_playlist_filename_array[@]}"
                ;;

            "n"|"N")
                continue
                ;;
        esac
    fi
}

concatenateGeneratedPlaylistFiles()
{
    local music_directory
    declare -a playlist_filename_array

    for music_directory in "${music_directory_array[@]}"
    do
        playlist_filename_array+=("${music_directory##*/}.${playlist_filename_suffix}")
    done

    /bin/cat "${playlist_filename_array[@]}" > "${playlist_all_filename}"
}

generatePlaylistFiles()
{
    local music_directory
    local playlist_filename

    for music_directory in "${music_directory_array[@]}"
    do
        playlist_filename="${music_directory##*/}.${playlist_filename_suffix}"
        /usr/bin/find "${music_directory}" -type f -name "*.${music_filename_suffix}" | /usr/bin/sort --ignore-case > "${playlist_filename}"
    done
}

main()
{
    checkAndPromptExistingPlaylists

    generatePlaylistFiles

    concatenateGeneratedPlaylistFiles
}

main
