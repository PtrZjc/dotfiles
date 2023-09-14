local wezterm = require 'wezterm'
local act = wezterm.action

local config = {}
local open_command

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Determine the open command based on the OS
if wezterm.target_triple:find("darwin") then
  open_command = "open"
else
  open_command = "xdg-open"
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
  {key="CapsLock", mods="NONE", action=act{SendString="\x1b"}, -- CapsLock as escape
  },
}

-- custom hyperlinks

config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
  regex = [[HUBZ-(\d+)]],
  format = 'https://jira.allegrogroup.com/browse/HUBZ-$1',
})

table.insert(config.hyperlink_rules, {
  regex = [=[["' ](\w[-\w]+\/[-\w\.]+)["' ]]=],
  format = 'https://www.github.com/$1',
  highlight = 1
})

return config
