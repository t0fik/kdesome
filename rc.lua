--[[
     KDEsome awesome WM config
     github.com/denydias/kdesome
     based on github.com/copycat-killer/awesome-copycats Powerarrow Darker
--]]

-- {{{ Required libraries
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
                  require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local lain      = require("lain")
local keydoc    = require("keydoc")
-- }}}

-- {{{ Error handling
-- Startup errorsc
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Runtime errors
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
--     Only awesome related. Other apps startup are managed by KDE.
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

-- Compositor
run_once("compton -b --config " .. os.getenv("HOME") .. "/.config/awesome/compton.conf")

-- uncluter
run_once("unclutter")
-- }}}

-- {{{ Variable definitions
-- localization
os.setlocale(os.getenv("LANG"))

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/kdesome/theme.lua")

-- common
home       = os.getenv("HOME")
config_dir = home .. "/.config/awesome"
theme_dir  = config_dir .. "/themes/kdesome"
modkey     = "Mod4"
altkey     = "Mod1"
terminal   = "terminator" or "xterm"

-- user defined
icons       = home .. "/.kde/share/icons"
wallpapers  = home .. "/Sync/Dropbox/Photos/Desktop/"
browser     = "firefox"
pim         = "kontact --geometry 1304x688+30+48"
im          = "kopete --geometry 300x748+0+18"
microblog   = "choqok --geometry 400x748+964+18"
filemanager = "dolphin"
kdeconf     = "systemsettings"
aweconf     = "kate --new --name aweconf " .. home .. "/.conkyrc " ..
              config_dir .. "/compton.conf " .. theme_dir .. "/theme.lua "
              .. config_dir .. "/rc.lua"
menutheme   = "sed 's/xdgmenu = {    /xdgmenu = { theme = { height = 16, width = 300 },\\n    /'"
menugen     = "xdg_menu --format awesome --root-menu /etc/xdg/menus/applications.menu | " .. menutheme .. " > " .. config_dir .. "/xdg_menu.lua"
-- }}}

-- {{{ Layouts and Tags
-- Available layouts
local layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
}

-- Available tags
tags = {
   names = { "1", "2", "3", "4", "5", "6" },
   layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] }
}

-- Set tags and layouts for each attached screen
for s = 1, screen.count() do
   tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Random Wallpapers
-- Get the list of files from a directory. Must be all images or folders and non-empty
function scanDir(directory)
    local i, fileList, popen = 0, {}, io.popen
    for filename in popen([[find "]] ..directory.. [[" -type f]]):lines() do
        i = i + 1
        fileList[i] = filename
    end
    return fileList
end
wallpaperList = scanDir(wallpapers)

-- Apply a random wallpaper on startup
for s = 1, screen.count() do
    gears.wallpaper.maximized(wallpaperList[math.random(1, #wallpaperList)], s, true)
end

-- Apply a random wallpaper every changeTime seconds
changeTime = 3600
wallpaperTimer = timer { timeout = changeTime }
wallpaperTimer:connect_signal("timeout", function()
    for s = 1, screen.count() do
        gears.wallpaper.maximized(wallpaperList[math.random(1, #wallpaperList)], s, true)
    end
    -- stop the timer (we don't need multiple instances running at the same time)
    wallpaperTimer:stop()
    -- restart the timer
    wallpaperTimer.timeout = changeTime
    wallpaperTimer:start()
end)

-- initial start when rc.lua is first run
wallpaperTimer:start()
-- }}}

-- {{{ Menu
-- Submenus
require("xdg_menu")
sys_menu = {
  { "Terminal", terminal, icons .. "/kAwOkenWhite/clear/22x22/apps/terminal.png" },
  { "Configurar KDE", kdeconf, icons .. "/kAwOkenWhite/clear/22x22/apps/kdeapp.png" },
  { "Configurar awesome", aweconf, icons .. "/kAwOkenWhite/clear/22x22/apps/window-manager.png" }}

-- Main Menu
mymainmenu = awful.menu.new({ items = {
  { "Firefox", browser, icons .. "/kAwOkenWhite/clear/22x22/apps/firefox.png" },
  { "Kontact", pim, icons .. "/kAwOkenWhite/clear/22x22/apps/kontact.png" },
  { "Kopete", im, icons .. "/kAwOkenWhite/clear/22x22/apps/kopete.png" },
  { "Choqok", microblog, icons .. "/kAwOkenWhite/clear/22x22/apps/choqok.png" },
  { "Dolphin", filemanager, icons .. "/kAwOkenWhite/clear/22x22/apps/file-manager.png" },
  { "Aplicativos", xdgmenu, icons .. "/kAwOkenWhite/clear/22x22/places/folder-script.png" },
  { "Sistema", sys_menu, icons .. "/kAwOkenWhite/clear/22x22/start-here/start-here-slackware1.png" }}})
-- }}}

-- {{{ Wibox
markup = lain.util.markup

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = awful.widget.textclock(" %a %d %b %H:%M")

-- calendar
lain.widgets.calendar:attach(mytextclock, { font_size = 10 })

-- Battery
baticon = wibox.widget.imagebox(beautiful.widget_battery)
batwidget = wibox.widget.background(lain.widgets.bat({
    settings = function()
        if bat_now.perc == "N/A" then
            widget:set_markup(" AC ")
            baticon:set_image(beautiful.widget_ac)
            return
        elseif tonumber(bat_now.perc) <= 5 then
            baticon:set_image(beautiful.widget_battery_empty)
        elseif tonumber(bat_now.perc) <= 15 then
            baticon:set_image(beautiful.widget_battery_low)
        else
            baticon:set_image(beautiful.widget_battery)
        end
        widget:set_markup(" " .. bat_now.perc .. "% ")
    end
}), "#313131")

-- File System Notification
fswidget = lain.widgets.fs()

-- {{ Separators
-- Spacer
spr = wibox.widget.textbox(' ')
-- Left pointing arrow
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
-- Left pointing, lighter at left, darker at right arrow
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
-- Left pointing, darker at left, lighter at right arrow
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)
-- Right pointing arrow
arrl_r = wibox.widget.imagebox()
arrl_r:set_image(beautiful.arrl_r)
-- }}

-- Create a wibox for each screen and add it
mywibox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do

    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                            awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                            awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                            awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                            awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end),
                            awful.button({ }, 6, function () awful.layout.inc(layouts, 1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(spr)
    left_layout:add(mytaglist[s])
    left_layout:add(arrl_r)
    left_layout:add(spr)

    -- Widgets that are aligned to the upper right
    -- If you are moving widgets from a section with light grey background to dark grey or vice versa,
    -- use a replacement icon as appropriate from themes/powerarrow-darker/alticons so your icons match the bg.
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
        right_layout:add(spr)
        right_layout:add(arrl)
        right_layout:add(spr)
        right_layout:add(wibox.widget.systray())
        right_layout:add(spr)
        right_layout:add(arrl_ld)
        right_layout:add(baticon)
        right_layout:add(batwidget)
        right_layout:add(arrl_dl)
        right_layout:add(mytextclock)
    end
    right_layout:add(spr)
    right_layout:add(arrl_ld)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)
    mywibox[s]:set_widget(layout)

end
-- }}}

-- {{{ Mouse bindings
-- Root window
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    )
)

-- Clients
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}

-- {{{ Key bindings
-- {{ Global keys
globalkeys = awful.util.table.join(
    -- Assistance
    keydoc.group("Assistência"),
    awful.key({ modkey }, "F1", keydoc.display, "Esta ajuda*"),
    awful.key({ modkey }, "w",
        function ()
            mymainmenu:show({ keygrabber = true })
        end, "Menu principal"),
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end, "Esconde/mostra barra superior*"),
    awful.key({ modkey }, "d", function () awful.util.spawn(filemanager) end, "Abre gerenciador de arquivos*"),
    awful.key({ modkey, "Ctrl" }, "Return", function () awful.util.spawn(terminal) end, "Abre terminal em janela*"),
    awful.key({ modkey }, ",", function () awful.util.spawn(kdeconf) end, "Abre configurações do KDE*"),
    awful.key({ modkey, "Control" }, ",", function () awful.util.spawn(aweconf) end, "Abre configurações do awesome*"),
    awful.key({ altkey }, "c", function () lain.widgets.calendar:show(7) end, "Mostra calendário*"),
    awful.key({ altkey }, "h", function () fswidget.show(7) end, "Mostra uso do disco"),
    awful.key({ modkey, "Control", "Shift" }, "w", function () awful.util.spawn_with_shell(menugen) end, "Gera menu de aplicativos*"),
    awful.key({ modkey, "Control" }, "r", awesome.restart, "Reinicia awesome"),

    -- Focus management
    keydoc.group("Foco"),
    awful.key({ altkey }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end, "Foca janela anterior*"),
    awful.key({ altkey }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end, "Foca próxima janela*"),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end, "Alterna para janela focada anteriormente"),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto, "Foca próxima janela urgente"),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end, "Foca próxima tela"),

    -- Layout management (tile mode)
    keydoc.group("Layout (modo encaixe)"),
    awful.key({ modkey }, "l", function () awful.tag.incmwfact(0.05) end, "Aumenta largura mestre"),
    awful.key({ modkey }, "h", function () awful.tag.incmwfact(-0.05) end, "Diminui largura mestre"),
    awful.key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(1) end, "Aumenta número de mestres*"),
    awful.key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster(-1) end, "Diminui número de mestres*"),
    awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(1) end, "Aumenta número de colunas*"),
    awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol(-1) end, "Diminui número de colunas*"),
    awful.key({ modkey, "Ctrl" }, "space", function () awful.layout.inc(layouts, 1) end, "Próximo layout*"),
    awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end, "Layout anterior"),
    awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1) end, "Troca com a próxima janela"),
    awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx(-1) end, "Troca com a janela anterior")
)

-- { Navigation and tag management
-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        keydoc.group("Navegação e Tags"),
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end,
                  i == 5 and "Mostra apenas tag #" or nil),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  i == 5 and "Mostra/esconde tag #" or nil),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end,
                  i == 5 and "Move janela para tag #" or nil),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end,
                  i == 5 and "Adiciona janela na tag #" or nil))
end

globalkeys = awful.util.table.join(globalkeys,
    keydoc.group("Navegação e Tags"),
    awful.key({ modkey }, "Left", awful.tag.viewprev, "Tag anterior"),
    awful.key({ modkey }, "Right", awful.tag.viewnext, "Próxima tag"),
    awful.key({ modkey }, "Escape", awful.tag.history.restore, "Retorna para tag anterior"),
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end, "Vai para tag anterior ocupada*"),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end, "Vai para próxima tag ocupada*")
)
-- }
-- }}

-- {{ Client Keys
clientkeys = awful.util.table.join(
    keydoc.group("Janelas"),
    awful.key({ modkey }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end, "Minimiza"),
    awful.key({ modkey }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end, "Maximiza"),
    awful.key({ modkey }, "f", function (c) c.fullscreen = not c.fullscreen end, "Alterna para tela cheia"),
    awful.key({ modkey }, "o", awful.client.movetoscreen, "Move para outra tela"),
    awful.key({ modkey }, "s", function (c) c.sticky = not c.sticky end, "Coloca em todas as tags*"),
    awful.key({ modkey }, "t", function (c) c.ontop = not c.ontop end, "Sobe janela*"),
    awful.key({ modkey }, "x", function (c) c:kill() end, "Mata aplicação*"),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle, "Torna flutuante" ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end, "Coloca no mestre (modo encaixe)"),
    awful.key({ modkey }, "i",
        function (c)
            local result = "<b>Informações da Janela do Aplicativo: " .. c.class .. "</b>\n"
            result = result .. "<b>Nome:</b> " .. c.name .. "\n"
            result = result .. "<b>Instância:</b> " .. c.instance .. "\n"
            if c.role then
                result = result .. "<b>Papel:</b> " .. c.role .. "\n"
            else
                result = result .. "<b>Papel:</b> Não definido\n"
            end
            result = result .. "<b>Tipo:</b> " .. c.type .. "\n"
            result = result .. "<b>PID:</b> " .. c.pid .. "\n"
            result = result .. "<b>XID:</b> " .. c.window
            local appicon = ""
            if c.icon then
                appicon = c.icon
            else
                appicon = icons .. "/kAwOkenWhite/clear/22x22/actions/info2.png"
            end
            naughty.notify({
                text = result,
                icon = appicon,
            })
        end, "Informações da janela do aplicativo*")
)
-- }}

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     maximized_vertical   = false,
                     maximized_horizontal = false,
                     buttons = clientbuttons,
                     size_hints_honor = false } },

    -- {{ Application rules
    -- Firefox: all clients in screen 1, tag 1
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][1] } },

    -- { Kontact
    -- All clients in screen 1, tag 2
    { rule = { class = "Kontact" },
      properties = { tag = tags[1][2] } },

    -- Set geometry for main client
    { rule = { class = "Kontact",
               role = "MainWindow#1" },
      properties = { geometry = { x = 30,
                                  y = 48,
                                  width = 1304,
                                  height = 688 } } },

    -- Focus mail composer, get focus when opened
    { rule = { class = "Kontact",
               role = "kmail-composer#1" },
      properties = { switchtotag = true,
                     focus = true } },
    -- }

    -- { Kopete
    -- All clients in screen 1, tag 3
    { rule = { class = "Kopete" },
      properties = { tag = tags[1][3] } },

    -- Set geometry for main client
    { rule = { class = "Kopete",
               role = "MainWindow#1" },
      properties = { geometry = { x = 0,
                                  y = 18,
                                  width = 300,
                                  height = 748 } } },

    -- Set geometry and prevent focus steal for secondary clients (chats)
    { rule = { class = "Kopete",
               role = "MainWindow#2" },
      properties = { switchtotag = false,
                     focus = false,
                     geometry = { x = 302,
                                  y = 384,
                                  width = 660,
                                  height = 382 } } },
    -- }

    -- { Choqok
    -- All clients in screen 1, tag 3
    { rule = { class = "Choqok" },
      properties = { tag = tags[1][3] } },

    -- Set geometry for main client
    { rule = { class = "Choqok",
               role = "MainWindow#1" },
      properties = { geometry = { x = 964,
                                  y = 18,
                                  width = 400,
                                  height = 748 } } },
    -- }

    -- Conky: as widget in screen 1, tag 6 and set geometry
    { rule = { class = "Conky" },
      properties = { tag = tags[1][6],
                     switchtotag = true,
                     floating = true,
                     ontop = false,
                     skip_taskbar = true,
                     geometry = { x = 0,
                                  y = 18,
                                  height = 750 } } },

    -- { System Config
    -- KDE System Settings: all clients in screen 1, tag 6, set geometry and get focus when opened
    { rule = { class = "Systemsettings",
               role = "MainWindow#1" },
      properties = { tag = tags[1][6],
                     switchtotag = true,
                     focus = true,
                     geometry = { x = 264,
                                  y = 18,
                                  width = 1100,
                                  height = 748 } } },

    -- Kate instance for awesome config: all clients in screen 1, tag 6, set geometry and get focus when opened
    { rule = { class = "Kate",
               instance = "aweconf",
               role = "__KateMainWindow#1" },
      properties = { tag = tags[1][6],
                     switchtotag = true,
                     focus = true,
                     geometry = { x = 264,
                                  y = 18,
                                  width = 1100,
                                  height = 748 } } },
    -- }

    -- Kate regular instances: set geometry
    { rule = { class = "Kate",
               instance = "kate",
               role  = "__KateMainWindow#1" },
      properties = { focus = true,
                     geometry = { y = 18,
                                  width = 683,
                                  height = 748 } } },

    -- }}
}
-- }}}

-- {{{ Signals
-- Functions to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    -- Prevent overlap and off screen
    if not startup and not c.size_hints.user_position
       and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
    end
end)

-- Apply rules after an application startup finishes
client.connect_signal("spawn::completed", function (c)
  awful.rules.apply(c)
end)

-- Manage features when a client get the focus
client.connect_signal("focus",
    function(c)
        -- No border for maximized clients, full screen flash content and special ones
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_color = beautiful.border_normal
        elseif c.name == "plugin-container" then
            local flash_client = c
            mt = timer({timeout=0.1})
            mt:connect_signal("timeout",function() c.fullscreen = true
            mt:stop() end)
            mt:start()
        -- Unless they are special ones
        elseif c.class == "Conky" or c.class == "Kruler" or c.class == "krunner" then
            c.border_width = 0
        else
            c.border_color = beautiful.border_focus
            -- Also raise the client when it get the focus
            client.focus = c
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)


-- Arrange signal handler
for s = 1, screen.count() do
    screen[s]:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then -- Fine grained borders and floaters control
            for _, c in pairs(clients) do
                -- Floaters almost always have borders
                if (awful.client.floating.get(c) or layout == "floating") and (c.class ~= "Conky" and c.class ~= "Kruler" and c.class ~= "krunner") then
                    c.border_width = beautiful.border_width
                -- Unless they are special ones
                elseif c.class == "Conky" or c.class == "Kruler" or c.class == "krunner" then
                    c.border_width = 0
                -- No borders with only one visible client
                elseif #clients == 1 or layout == "max" then
                    clients[1].border_width = 0
                else
                    c.border_width = beautiful.border_width
                end
            end
        end
    end)
end
-- }}}
