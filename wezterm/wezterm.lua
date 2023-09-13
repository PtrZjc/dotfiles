local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- theme
config.color_scheme = 'Argonaut'
config.font = wezterm.font 'MesloLGS Nerd Font'
config.font_size = 24
config.hide_tab_bar_if_only_one_tab = true
config.disable_default_mouse_bindings = true

config.keys = {
  {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}}, -- alt b -> back word, etc
  {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
  {key="LeftArrow", mods="SHIFT", action=wezterm.action{SendString="\x1bb"}},
  {key="RightArrow", mods="SHIFT", action=wezterm.action{SendString="\x1bf"}},
  {key="n", mods="CMD", action=wezterm.action.DisableDefaultAssignment}, -- disable new window hotkey
  {key="t", mods="CMD", action=wezterm.action.DisableDefaultAssignment}, -- disable new pane hotkey
}
return config

