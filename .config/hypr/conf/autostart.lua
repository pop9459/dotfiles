-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/configuring/core/autostart/
-- Equivalent of the old exec-once lines: runs once when Hyprland starts.

hl.on("hyprland.start", function()
    -- Set random wallpaper with hyprpaper
    hl.exec_cmd("~/.config/hypr/scripts/random-wallpaper.sh")

    -- Quickshell bar (replaced eww)
    hl.exec_cmd("quickshell -p ~/.config/quickshell/bar/")

    -- D-Bus environment update for keyring detection (fixes VS Code/Copilot CLI Secret Service API)
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd GTK_THEME")

    -- GNOME keyring daemon is started and unlocked by PAM (ly) at login; do not restart it here,
    -- or the new instance comes up locked and prompts for the password.
    -- polkit agent is handled by the hyprpolkitagent systemd user service.

    -- Blue light filter
    hl.exec_cmd("hyprsunset")
end)
