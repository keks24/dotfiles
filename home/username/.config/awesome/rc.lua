--[[
############################################################################
# Copyright 2020-2025 Ramon Fischer                                        #
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
--]]

--[[
Mod keys:

xmodmap:  up to 4 keys per modifier, (keycodes in parentheses):

shift       Shift_L (0x32),  Shift_R (0x3e)
lock        Caps_Lock (0x42)
control     Control_L (0x25),  Control_R (0x69)
mod1        Alt_L (0x40),  Alt_L (0xcc),  Meta_L (0xcd)
mod2        Num_Lock (0x4d)
mod3        ISO_Level5_Shift (0xcb)
mod4        Super_L (0x85),  Super_R (0x86),  Super_L (0xce),  Hyper_L (0xcf)
mod5        ISO_Level3_Shift (0x5c)
--]]

-- custom - 20200509 - rfischer: copy the configuration file from "/etc/xdg/awesome/rc.lua"
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
--beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
-- custom - 20240902T102247+0200 - rfischer: set "beautiful.init(gears.filesystem.get_configuration_dir() " to "themes/zenburn/theme.lua"
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
--terminal = "xterm"
-- custom - 20200510 - rfischer: set "terminal" to "tabbed -cr 2 st -w ''"
--terminal = "tabbed -cr 2 st -w ''"
-- custom 20201001 - rfischer: set "terminal" to "tabbed -cr 2 alacritty --embed ''"
terminal = "tabbed -cr 2 alacritty --embed ''"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    -- custom - 20240827T155351+0200 - rfischer: set "tile" layout as default
    --awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

-- custom - 20200510 - rfischer: add browser variable
browser = "firefox"
torbrowser = "torbrowser --torbrowser-version 10.5.10"
email = "thunderbird-bin"
downloader = "jdownloader"
scanner = "xsane"
office = "libreoffice"
terra_nil = "terra_nil"
the_forgotten_halls = "the_forgotten_halls"
setris = "setris"
minecraft = "minecraft-launcher"
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal },
                                    -- custom - 20200510 - rfischer: add browser variable
                                    { "open firefox", browser },
                                    { "open torbrowser", torbrowser },
                                    { "open thunderbird", email },
                                    { "open jdownloader", downloader },
                                    { "open xsane", scanner },
                                    { "open libreoffice", office },
                                    { "open minecraft", minecraft },
                                    { "open terra nil", terra_nil },
                                    { "open setris", setris },
                                    { "open the forgotten halls", the_forgotten_halls }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end

        -- custom - 20241111T110118+0100 - rfischer: scale wallpaper on each screen differently.
        local offset_x_percentage = -0.975
        local offset_y_percentage = 0.0
        -- get screen dimensions
        local screen_width = s.geometry.width
        local screen_height = s.geometry.height
        -- calculate pixel offset
        local offset_x_pixels = screen_width * offset_x_percentage
        local offset_y_pixels = screen_height * offset_y_percentage

        gears.wallpaper.maximized(wallpaper, screen[1], true)
        -- do not ignore aspect ratio and move the wallpaper by 97.5% (~1022 pixels) to the left.
        gears.wallpaper.maximized(wallpaper, screen[2], false, { x = offset_x_pixels, y = offset_y_pixels })
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    --awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    -- use custom tags on two seperate screens. see also: rule mapping.
    if s.index == 1 then
        awful.tag({ "terminal", "web", "e-mail", "office", "download", "image", "scan", "video", "vm", "game" }, screen[1], awful.layout.layouts[1])
    elseif s.index == 2 then
        awful.tag({ "terminal", "web", "e-mail", "office", "download", "image", "scan", "video", "vm", "game" }, screen[2], awful.layout.layouts[1])
    end

    -- increase number of master clients for some tags
    local tags = awful.tag.gettags(s.index)
    for _, tag in pairs(tags) do
        if tag.name == "terminal"
            or tag.name == "web"
            or tag.name == "e-mail"
            or tag.name == "office"
            or tag.name == "download" then
            awful.tag.setnmaster(2, tag)
        end
    end

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    -- custom - 20241206T144012+0100 - rfischer: manipulate window layout with arrow keys.
    --[[
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    --]]
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    --[[
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    --]]
    -- custom - 20241206T143148+0100 - rfischer: manipulate window layout with arrow keys.
    awful.key({ modkey,           }, "Up",    function () awful.client.incwfact(-0.05)        end,
              {description = "decrease master height factor", group = "layout"}),
    awful.key({ modkey,           }, "Down",  function () awful.client.incwfact( 0.05)        end,
              {description = "increase master height factor", group = "layout"}),
    awful.key({ modkey,           }, "Left",  function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey,           }, "Right", function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    -- custom - 20240827T165938+0200 - rfischer: comment the below line, in order to close focussed window with "modkey+x"
    --[[
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    --]]
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    -- custom - 20200618 - rfischer: add keyboard shortcut for screenshots via "import". use "zlib" compression level 8 (quality / 10) with adaptive png filtering. see also: file:///usr/share/doc/imagemagick-7.0.10.9/html/www/command-line-options.html#quality
    --- selection (left click + hold), focused screen (left click)
    awful.key({ }, "Print", function () awful.util.spawn_with_shell("\
                                            screenshot_file=\"/home/ramon/pictures/screenshots/$(date +%Y%m%dT%H%M%S%z)_screenshot.png\" && \
                                            import -frame -colorspace YPbPr -depth 16 -quality 80 \"${screenshot_file}\" && \
                                            feh --geometry 800x600 --scale-down \"${screenshot_file}\"") end),
    --- all displays
    awful.key({ "Shift" }, "Print", function () awful.util.spawn_with_shell("\
                                            screenshot_file=\"/home/ramon/pictures/screenshots/$(date +%Y%m%dT%H%M%S%z)_screenshot.png\" && \
                                            import -frame -window root -colorspace YPbPr -depth 16 -quality 80 \"${screenshot_file}\" && \
                                            feh --geometry 800x600 --scale-down \"${screenshot_file}\"") end),
    -- custom - 20200630 - rfischer: lock tty and lock screens via "physlock" (ctrl+alt+l)
    awful.key({ "Control", "Mod1" }, "l", function () awful.util.spawn_with_shell("/home/ramon/bin/locker") end)

)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    --awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
    -- custom - 20240827T165717+0200 - rfischer: close focussed window with "modkey+x"
    awful.key({ modkey            }, "x",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
-- custom - 20250516T082923+0200 - rfischer: also use key "0" (tag "10").
--for i = 1, 9 do
for i = 1, 10 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },



    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
    -- see function "watch_xwindows" at "/home/ramon/.config/zsh/zshrc.local" to get "instance" and "class" names
    -- always open "firefox" and "chromium" on "screen 2", tag "web" and focus "screen 2".
    { rule_any = { class = {
                    "firefox-esr",
                    "Tor Browser",
                    "Chromium-browser-chromium" } },
      properties = { screen = 2, tag = "web", switchtotag = true,
      function() awful.screen.focus(screen[2]) end } },
    -- always open "thunderbird" on "screen 2", tag "e-mail" and focus "screen 2".
    { rule_any = { instance = { "Mail", "Msgcompose" }, class = { "thunderbird" } },
      properties = { screen = 2, tag = "e-mail", switchtotag = true,
      function() awful.screen.focus(screen[2]) end } },
    -- always open "calendar" windows on "screen 2"
    { rule = { instance = "Calendar", class = "thunderbird" },
      properties = { screen = 2, tag = "e-mail" } },
    -- always open "libreoffice" on "screen 2", tag "office" and focus "screen 2".
    { rule_any = { class = {
                    "Soffice",
                    "libreoffice",
                    "libreoffice-startcenter",
                    "libreoffice-base",
                    "libreoffice-calc",
                    "libreoffice-draw",
                    "libreoffice-impress",
                    "libreoffice-math",
                    "libreoffice-writer" } },
      properties = { screen = 2, tag = "office", switchtotag = true,
      function() awful.screen.focus(screen[2]) end } },
    -- always open "jdownloader" on "screen 2", tag "download".
    { rule = { class = "org-jdownloader-update-launcher-JDLauncher" },
      properties = { screen = 2, tag = "download" } },
    -- always open "gimp" on "screen 1", tag "image" and focus "screen 1"
    { rule_any = { class = {
                    "Gimp",
                    "Gimp-2.10" } },
      properties = { screen = 1, tag = "image", switchtotag = true,
      function() awful.screen.focus(screen[1]) end } },
    -- always open "xsane" on "screen 1", tag "scan" and focus "screen 1"
    { rule = { class = "Xsane" },
      properties = { screen = 1, tag = "scan", switchtotag = true,
      function() awful.screen.focus(screen[1]) end } },
    -- always open "flashplayerdebugger" on "screen 1", tag "game" and focus "screen 1"
    { rule_any = { class = {
                    "Flashplayerdebugger",
                    "rs.ruffle.Ruffle" } },
      properties = { screen = 1, tag = "game", switchtotag = true,
      function() awful.screen.focus(screen[1]) end } },
    -- always open "vncviewer" on "screen 2", tag "vm" and focus "screen 2"
    { rule_any = { class = {
                    "Vncviewer",
                    "qemu-system-aarch64",
                    "Qemu-system-aarch64",
                    "qemu-system-x86_64",
                    "Qemu-system-x86_64" } },
      properties = { screen = 2, tag = "vm", switchtotag = true,
      function() awful.screen.focus(screen[2]) end } },
    -- always open "mpv" on "screen 1", tag "video", focus "screen 1" and "maximise" the window
    { rule = { class = "mpv" },
      properties = { screen = 1, tag = "video", switchtotag = true,
      function() awful.screen.focus(screen[1]) end,
      function(c) c.maximized = not c.maximized c:raise() end } },
    -- always open "Xephyr" on "screen 2", tag "video" and focus "screen 2"
    { rule_any = { class = {
                    "xephyr",
                    "Xephyr" } },
      properties = { screen = 2, tag = "video", switchtotag = true,
      function() awful.screen.focus(screen[1]) end } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        --[[
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
        --]]
        -- custom - 20200623 - rfischer: switch buttons
        { --left
            awful.titlebar.widget.closebutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            -- looks ugly, when using theme "zenburn"
            awful.titlebar.widget.minimizebutton (c),
            --awful.titlebar.widget.stickybutton   (c),
            --awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.ontopbutton (c),
            layout = wibox.layout.fixed.horizontal()
        },
        { -- middle
            { -- title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        { -- right
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal

    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
