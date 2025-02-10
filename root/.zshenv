############################################################################
# Copyright 2022-2025 Ramon Fischer                                        #
#                                                                          #
# Licensed under the Apache License, Version 2.0 (the "License");          #
# you may not use this file except in compliance with the License.         #
# You may obtain a copy of the License at                                  #
#                                                                          #
#     http://www.apache.org/licenses/LICENSE-2.0                           #
#                                                                          #
# Unless required by applicable law or agreed to in writing, software      #
# distributed under the License is distributed on an "AS IS" BASIS,        #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
# See the License for the specific language governing permissions and      #
# limitations under the License.                                           #
############################################################################

# global
## exports
### set a different configuration directory
export ZDOTDIR="${HOME}/.config/zsh"
### use the cache directory in "/root/"
export GRML_COMP_CACHE_DIR="${HOME}/.cache"
### set default scanner device
export SANE_DEFAULT_DEVICE="net:sane.local:genesys:libusb:001:003"
### use local man pages
export MANPATH="${HOME}/.local/share/man:${MANPATH}"
