local wezterm = require 'wezterm'
local act = wezterm.action

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.default_prog = { '/usr/local/bin/tmux', 'a' }

-- Theme config
config.color_scheme = 'Argonaut'
config.font = wezterm.font 'MesloLGS Nerd Font'
config.font_size = 24
config.hide_tab_bar_if_only_one_tab = true

-- Mouse config
config.disable_default_mouse_bindings = true
config.bypass_mouse_reporting_modifiers = "SHIFT"
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.OpenLinkAtMouseCursor,
  },
}

-- Keybindings config
config.keys = {
  {key="LeftArrow", mods="OPT", action=act{SendString="\x1bb"}}, -- alt b -> back word, etc
  {key="RightArrow", mods="OPT", action=act{SendString="\x1bf"}},
  {key="LeftArrow", mods="SHIFT", action=act{SendString="\x1bb"}},
  {key="RightArrow", mods="SHIFT", action=act{SendString="\x1bf"}},
  {key="n", mods="CMD", action=act.DisableDefaultAssignment}, -- disable new window hotkey
  {key="t", mods="CMD", action=act.DisableDefaultAssignment}, -- disable new pane hotkey
}

return config
