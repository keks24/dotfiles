local themes_path = require("gears.filesystem").get_themes_dir()
local theme = dofile(themes_path .. "zenburn/theme.lua")

    theme.font = "terminus 8"
    theme.useless_gap = "5"

return theme
