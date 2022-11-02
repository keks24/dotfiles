#!/bin/bash
#############################################################################
# Copyright 2022 Ramon Fischer                                              #
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

home_directory="${HOME}"
youtube_url="https://www.youtube.com"
declare -A youtube_channel_array
youtube_channel_array=( \
                        ["domian_live_2021_fanclub"]="${youtube_url}/user/danielskate14" \
                        ["domian4ever"]="${youtube_url}/channel/UCS3EcW5FS_p0MzapOPcNooA" \
                        ["domianarchiv.de"]="${youtube_url}/c/DomianarchivDe" \
                      )
music_directory_path="${home_directory}/music"
playlist_directory_path="${music_directory_path}/playlists"
youtube_download_archive_list_directory_path="${music_directory_path}/youtube-dl/archive_lists"

for youtube_channel in "${!youtube_channel_array[@]}"
do
    youtube_playlist_file="${playlist_directory_path}/youtube_-_${youtube_channel}.m3u8"
    youtube_download_archive_list_file="${youtube_download_archive_list_directory_path}/youtube_-_${youtube_channel}.list"

    /usr/bin/yt-dlp \
        --ignore-config \
        --download-archive="${youtube_download_archive_list_file}" \
        --force-download-archive \
        --get-id \
        "${youtube_channel_array[${youtube_channel}]}" \
            | /usr/bin/xargs --replace="{}" echo "${youtube_url}/watch?v={}" \
            | /usr/bin/tee --append "${youtube_playlist_file}"
done
