--[[
#############################################################################
# Copyright 2024 Ramon Fischer                                              #
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
--]]

local dpi         = require("beautiful.xresources").apply_dpi
local gears       = require("gears.filesystem")
local themes_path = gears.get_themes_dir()
local theme       = dofile(themes_path .. "zenburn/theme.lua")

    theme.font = "terminus 8"
    theme.useless_gap = "dpi(5)"

return theme
