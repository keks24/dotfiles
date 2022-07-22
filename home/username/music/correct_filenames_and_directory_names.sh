#!/bin/bash
# correct filenames and directory names in order to be conform with the fat naming convention.
# the slash character is left out, since linux does not allow this character in filenames.
declare -a fat_illegal_character_array
fat_illegal_character_array=("<" ">" ":" "\"" "\\" "?" "*")
fat_illegal_character=
declare -a music_directory_array
music_directory_array=("audiobooks" "normal_music" "playlists" "podcasts" "record" "unusual_music")
music_directory=

for music_directory in "${music_directory_array[@]}"
do
    for fat_illegal_character in "${fat_illegal_character_array[@]}"
    do
        /usr/bin/find "${music_directory}" \
            -regextype posix-extended \
            \( \
                -type f -iregex ".*${fat_illegal_character}.*" \
                -or \
                -type d -iregex ".*${fat_illegal_character}.*" \
            \) \
            -exec /usr/bin/rename --verbose "${fat_illegal_character}" "_" "{}" +
    done
done
