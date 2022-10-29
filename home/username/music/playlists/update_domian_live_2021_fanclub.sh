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
youtube_channel_name="domian_live_2021_fanclub"
youtube_channel_url="https://www.youtube.com/user/danielskate14"
youtube_video_url="https://www.youtube.com/watch?v="
youtube_playlist_file="${home_directory}/music/playlists/youtube_-_${youtube_channel_name}.m3u8"
download_archive_list_file="${home_directory}/music/youtube-dl/archive_lists/youtube_-_${youtube_channel_name}.list"

/usr/bin/yt-dlp \
    --download-archive="${download_archive_list_file}" \
    --force-download-archive \
    --get-id "${youtube_channel_url}" \
        | /usr/bin/xargs --replace="{}" echo "${youtube_video_url}{}" \
        | /usr/bin/tee --append "${youtube_playlist_file}"
