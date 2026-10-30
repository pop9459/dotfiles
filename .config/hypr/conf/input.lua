---------------
---- INPUT ----
---------------

-- See https://wiki.hypr.land/configuring/core/config-options/
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity   = -0.3,   -- -1.0 - 1.0, 0 means no modification.
        accel_profile = "flat", -- Disable mouse acceleration

        touchpad = {
            natural_scroll       = true,
            clickfinger_behavior = true, -- 1/2/3-finger press = LMB/RMB/MMB (2-finger press needed for SUPER+RMB resize)
        },
    },
})

-- See https://wiki.hypr.land/configuring/gestures/
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- Example per-device config (use `hyprctl devices` for the exact name)
-- See https://wiki.hypr.land/configuring/core/devices/
-- hl.device({
--     name        = "epic-mouse-v1",
--     sensitivity = -0.5,
-- })
