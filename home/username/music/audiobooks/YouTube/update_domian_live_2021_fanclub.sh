#!/bin/bash
if [[ ! -d "Domian Live 2021 FanClub" ]]
then
    echo -e "\e[01;31mCould not find directory: 'Domain Live 2021 FanClub' or is not a directory.\e[0m" >&2
    exit 1
else
    /usr/bin/youtube-dl --ignore-config --config-location="/home/ramon/.config/youtube-dl/config_domian"
fi
