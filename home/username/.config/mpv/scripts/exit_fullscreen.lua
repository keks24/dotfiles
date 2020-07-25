-- requirements
---- 1) "keep-open" must be set to "yes"

-- functions
---- 1) exit fullscreen, when end of file reached

function exitFullScreen(name, value)
    if value
    then
        local pause = mp.get_property_native("pause")

        if pause
        then
            local fullscreen = mp.get_property_native("fullscreen")

            if fullscreen
            then
                mp.set_property_native("fullscreen", false)
            end
        end
    end
end

mp.observe_property("eof-reached", "bool", exitFullScreen)
