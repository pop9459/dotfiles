---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/configuring/core/binds/ and .../core/dispatchers/
-- Old flag mapping: binde = repeating, bindl = locked, bindel = locked+repeating,
-- bindr = release, bindm = mouse.

local programs = require("conf.programs")
local mainMod  = "SUPER" -- Sets "Windows" key as main modifier

local function key(mods, k)
    if mods == nil or mods == "" then return k end
    return mods .. " + " .. k
end

local function exec(cmd) return hl.dsp.exec_cmd(cmd) end

-- OS control
-- hl.bind(key(mainMod, "M"), exec("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(key(mainMod, "DELETE"), exec("hyprlock"))

-- Restart quickshell bar (e.g. after a matugen theme change)
hl.bind(key(mainMod .. " + CTRL", "R"), exec("killall quickshell & sleep 1 && quickshell -p ~/.config/quickshell/bar/"))

-- App launchers
hl.bind(key("SUPER", "SUPER_L"), exec(programs.menu), { release = true })
hl.bind(key(mainMod, "T"), exec(programs.terminal))
hl.bind(key(mainMod, "E"), exec(programs.fileManager))
hl.bind(key(mainMod, "R"), exec(programs.menu))
hl.bind(key(mainMod, "B"), exec(programs.browser))
hl.bind(key(mainMod .. " + SHIFT", "S"), exec("hyprshot -m region --clipboard-only"))

-- Manipulate focused window
hl.bind(key(mainMod, "Q"), hl.dsp.window.close())
hl.bind(key(mainMod, "V"), hl.dsp.window.float({ action = "toggle" }))
hl.bind(key(mainMod, "P"), hl.dsp.window.pseudo()) -- dwindle
hl.bind(key(mainMod, "F"), hl.dsp.window.fullscreen())

-- Direction keys: vim keys and arrow keys
local directions = {
    { keys = { "h", "left" },  dir = "left",  dx = -40, dy = 0 },
    { keys = { "j", "down" },  dir = "down",  dx = 0,   dy = 40 },
    { keys = { "k", "up" },    dir = "up",    dx = 0,   dy = -40 },
    { keys = { "l", "right" }, dir = "right", dx = 40,  dy = 0 },
}

for _, d in ipairs(directions) do
    for _, k in ipairs(d.keys) do
        -- Resize active window
        hl.bind(key(mainMod .. " + ALT", k),
            hl.dsp.window.resize({ x = d.dx, y = d.dy, relative = true }), { repeating = true })
        -- Move focus
        hl.bind(key(mainMod, k), hl.dsp.focus({ direction = d.dir }))
        -- Move window within the workspace
        hl.bind(key(mainMod .. " + SHIFT", k), hl.dsp.window.move({ direction = d.dir }))
    end
end

-- Previous/next workspace: j/h/left = previous, k/l/right = next (same as before;
-- note up/down arrows were never bound for this)
local wsPrev = { "j", "h", "left" }
local wsNext = { "k", "l", "right" }
for _, k in ipairs(wsPrev) do
    hl.bind(key(mainMod .. " + CTRL + SHIFT", k), hl.dsp.window.move({ workspace = "e-1", follow = true }))
    hl.bind(key(mainMod .. " + CTRL", k),         hl.dsp.focus({ workspace = "e-1" }))
end
for _, k in ipairs(wsNext) do
    hl.bind(key(mainMod .. " + CTRL + SHIFT", k), hl.dsp.window.move({ workspace = "e+1", follow = true }))
    hl.bind(key(mainMod .. " + CTRL", k),         hl.dsp.focus({ workspace = "e+1" }))
end

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local k = tostring(i % 10) -- 10 maps to key 0
    hl.bind(key(mainMod, k),             hl.dsp.focus({ workspace = i }))
    hl.bind(key(mainMod .. " + SHIFT", k), hl.dsp.window.move({ workspace = i, follow = true }))
end

-- Scroll through workspaces with mainMod + scroll
hl.bind(key(mainMod, "mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(key(mainMod, "mouse_up"),   hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace (scratchpad)
-- hl.bind(key(mainMod, "S"),             hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(key(mainMod .. " + SHIFT", "S"), hl.dsp.window.move({ workspace = "special:magic" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(key(mainMod, "mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(key(mainMod, "mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys for volume and LCD brightness
local lockedRepeat = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"), lockedRepeat)
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),      lockedRepeat)
hl.bind("XF86AudioMute",        exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     lockedRepeat)
hl.bind("XF86AudioMicMute",     exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   lockedRepeat)
hl.bind("XF86MonBrightnessUp",
    exec([[sh -lc 'brightnessctl -e4 -n2 set 5%+; quickshell ipc -p "$HOME/.config/quickshell/bar" call brightness popup']]),
    lockedRepeat)
hl.bind("XF86MonBrightnessDown",
    exec([[sh -lc 'brightnessctl -e4 -n2 set 5%-; quickshell ipc -p "$HOME/.config/quickshell/bar" call brightness popup']]),
    lockedRepeat)

-- Requires playerctl
hl.bind("XF86AudioNext",  exec("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  exec("playerctl previous"),   { locked = true })

-- Elite Dangerous voice assistant (~/Documents/_MyProjects/EliteDangerousAsistant)
-- Scroll Lock: listen / finish speaking / stop answer; Shift+Scroll Lock: new conversation
hl.bind("Scroll_Lock",           exec("~/.local/bin/ed-assistant ctl listen"))
hl.bind(key("SHIFT", "Scroll_Lock"), exec("~/.local/bin/ed-assistant ctl reset"))

-- Night light toggle
hl.bind(key(mainMod, "N"), exec("~/.config/hypr/scripts/nightlight-toggle.sh"))
