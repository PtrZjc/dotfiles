local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
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

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  pane:send_text 'tmux new -s 0 || tmux attach -t 0\n'
end)

-- Theme config
config.color_scheme = "Argonaut"
config.font = wezterm.font("MesloLGS Nerd Font")
config.font_size = 24
config.hide_tab_bar_if_only_one_tab = true

-- Mouse config
config.disable_default_mouse_bindings = true
config.bypass_mouse_reporting_modifiers = "SHIFT"
config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.OpenLinkAtMouseCursor,
	},
}

-- Keybindings config
-- opt + del -> delete word before cursor
-- cmd + del -> delete word after cursor
-- cmd + opt + del -> delete line
-- ctrl + opt + del -> delete line before the cursor
-- ctrl + cmd + del -> delete line after the cursor
config.keys = {
	{ key = "LeftArrow", mods = "CMD", action = act({ SendString = "\x01" }) }, -- ctrl+a -> beginning of line
	{ key = "RightArrow", mods = "CMD", action = act({ SendString = "\x05" }) }, -- ctrl+e -> end of line
	{ key = "LeftArrow", mods = "OPT", action = act({ SendString = "\x1bb" }) }, -- alt+b -> back word, etc
	{ key = "RightArrow", mods = "OPT", action = act({ SendString = "\x1bf" }) },
	{ key = "LeftArrow", mods = "SHIFT", action = act({ SendString = "\x1bb" }) },
	{ key = "RightArrow", mods = "SHIFT", action = act({ SendString = "\x1bf" }) },
	{ key = "Backspace", mods = "CMD|OPT", action = act({ SendString = "\x15" }) }, -- ctrl+u -> delete line
	{ key = "Backspace", mods = "CMD", action = act({ SendString = "\x1bd" }) }, -- alt+d -> delete word before cursor
	{ key = "u", mods = "CMD", action = wezterm.action({ SendString = "\x1f" }) },-- Ctrl+_ -> undo	
	{ key = "n", mods = "CMD", action = act.DisableDefaultAssignment }, -- disable new window hotkey
	{ key = "t", mods = "CMD", action = act.DisableDefaultAssignment }, -- disable new pane hotkey
	{
		key = "CapsLock",
		mods = "NONE",
		action = act({ SendString = "\x1b" }), -- CapsLock as escape
	},
	{ 
		key = "Delete", 
		mods = "CTRL|OPT", 
		action = wezterm.action({ SendString = "\x15" })  -- This sends Ctrl+U
	},
	{ 
		key = "Delete", 
		mods = "CTRL|CMD", 
		action = wezterm.action({ SendString = "\x0b" })  -- This sends Ctrl+K
	},
	{
		key = "LeftArrow",
		mods = "CTRL",
		action = wezterm.action{SendString = "\x1b[1;5D"}
	  },
	  -- Ctrl + Right Arrow
	  {
		key = "RightArrow",
		mods = "CTRL",
		action = wezterm.action{SendString = "\x1b[1;5C"}
	  },
	}

-- custom hyperlinks

config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
	regex = [[HUBZ-(\d+)]],
	format = "https://jira.allegrogroup.com/browse/HUBZ-$1",
})

table.insert(config.hyperlink_rules, {
	regex = [=[["' ](\w[-\w]+\/[-\w\.]+)["' ]]=],
	format = "https://www.github.com/$1",
	highlight = 1,
})

return config
