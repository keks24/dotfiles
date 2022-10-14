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

if [[ ! -d "./Domian Live 2021 FanClub" ]]
then
    echo -e "\e[01;31mCould not find directory: './Domain Live 2021 FanClub' or is not a directory.\e[0m" >&2
    exit 1
else
    /usr/bin/youtube-dl --ignore-config --config-location="/home/ramon/.config/youtube-dl/config_domian"
fi
