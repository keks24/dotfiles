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

# define global variables
home_directory="${HOME}"
aria2c_netrc_path="${home_directory}/.cache/aria2/netrc"
aria2c_save_session="${home_directory}/.cache/aria2/aria2_session.gz"
podcast_audio_format="opus"
podcast_rss_url="https://verbraucherpod.podigee.io/feed/${podcast_audio_format}"
podcast_url_list=$(/usr/bin/curl --silent --show-error "${podcast_rss_url}" \
                    | /usr/bin/gawk \
                        --field-separator='"' \
                        --assign="podcast_audio_format=.${podcast_audio_format}.*feed" \
                        '$0 ~ podcast_audio_format { print $2 }')
declare -a podcast_url_array
declare -a podcast_audio_file_array
ffmpeg_output_audio_format="aac"

while read -r podcast_url
do
    podcast_url_array+=("${podcast_url}")
done <<< "${podcast_url_list}"

/usr/bin/aria2c \
    --force-sequential="true" \
    --continue="true" \
    --auto-save-interval="30" \
    --http-accept-gzip="true" \
    --netrc-path="${aria2c_netrc_path}" \
    --max-concurrent-downloads="4" \
    --max-connection-per-server="8" \
    --min-split-size="4M" \
    --split="8" \
    --save-session="${aria2c_save_session}" \
    --save-session-interval="60" \
    "${podcast_url_array[@]}"

podcast_audio_file_array=(*."${podcast_audio_format}")
for podcast_audio_file in "${podcast_audio_file_array[@]}"
do
    /usr/bin/ffmpeg \
        -i "${podcast_audio_file}" \
        -n \
        -codec:a aac \
        -b:a 128k \
        -ar:a 44100 \
        -filter:a "volume=1.2" \
        "${podcast_audio_file//\.${podcast_audio_format}/.${ffmpeg_output_audio_format}}"

    /bin/rm --force --verbose "${podcast_audio_file}"
done
