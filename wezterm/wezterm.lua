local wezterm = require("wezterm")
local act = wezterm.action
local config = {}
local open_command

if wezterm.config_builder then config = wezterm.config_builder() end

-- Determine the open command based on the OS
if wezterm.target_triple:find("darwin") then
    open_command = "open"
else
    open_command = "xdg-open"
end

-- General config
config.color_scheme = "Argonaut"
config.font = wezterm.font("MesloLGS Nerd Font")
config.font_size = 24
config.hide_tab_bar_if_only_one_tab = true
config.adjust_window_size_when_changing_font_size = false

-- Keybindings config

local function getSplitPaneConfig(direction)
    return {
        key = direction .. 'Arrow',
        mods = "CTRL|CMD",
        action = act.SplitPane {direction = direction, size = {Percent = 50}}
    }
end

local function getActivatePaneDirectionConfig(direction)
    return {
        key = direction .. 'Arrow',
        mods = "CTRL",
        action = act.ActivatePaneDirection(direction)
    }
end

local function getAdjustPaneSizeConfig(direction)
    return {
        key = direction .. 'Arrow',
        mods = "CTRL|OPT",
        action = act.AdjustPaneSize {direction, 5}
    }
end

-- Bash Shortcuts:  https://gist.github.com/tuxfight3r/60051ac67c5f0445efee 
config.keys = {
    getSplitPaneConfig('Left'), getSplitPaneConfig('Up'),
    getSplitPaneConfig('Down'), getSplitPaneConfig('Right'),
    getActivatePaneDirectionConfig('Left'),
    getActivatePaneDirectionConfig('Up'),
    getActivatePaneDirectionConfig('Down'),
    getActivatePaneDirectionConfig('Right'),
    getAdjustPaneSizeConfig('Left'),
    getAdjustPaneSizeConfig('Up'),
    getAdjustPaneSizeConfig('Down'),
    getAdjustPaneSizeConfig('Right'),
    {key = "LeftArrow", mods = "CMD", action = act({SendString = "\x01"})}, -- ctrl+a -> beginning of line
    {key = "RightArrow", mods = "CMD", action = act({SendString = "\x05"})}, -- ctrl+e -> end of line
    {key = "LeftArrow", mods = "OPT", action = act({SendString = "\x1bb"})}, -- alt+b -> back word, etc
    {key = "RightArrow", mods = "OPT", action = act({SendString = "\x1bf"})}, -- alt+f -> forward word, etc
    {key = "LeftArrow", mods = "SHIFT", action = act({SendString = "\x1bb"})}, -- alt+b -> back word, etc
    {key = "RightArrow", mods = "SHIFT", action = act({SendString = "\x1bf"})}, -- alt+f -> forward word, etc
    {key = "Backspace", mods = "CMD", action = act({SendString = "\x1bd"})}, -- alt+d -> delete word before cursor
    {key = 'w', mods = 'CMD', action = act.CloseCurrentPane {confirm = true}},
    {key = 'w', mods = 'CTRL', action = act.CloseCurrentPane {confirm = true}},
    {key = 'UpArrow', mods = 'SHIFT', action = act.Nop},
    {key = 'DownArrow', mods = 'SHIFT', action = act.Nop}
}

config.mouse_bindings = {
    {
        event = {Up = {streak = 1, button = "Left"}},
        mods = "NONE",
        action = act.Nop
    }, {
        event = {Down = {streak = 1, button = {WheelUp = 1}}},
        mods = 'CTRL',
        action = act.IncreaseFontSize
    }, {
        event = {Down = {streak = 1, button = {WheelDown = 1}}},
        mods = 'CTRL',
        action = act.DecreaseFontSize
    }, {
        event = {Up = {streak = 1, button = 'Left'}},
        mods = 'CTRL',
        action = act.OpenLinkAtMouseCursor
    }

}

-- custom hyperlinks

config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
    regex = [[LDSI-(\d+)]],
    format = "https://jira.sportradar.ag/browse/LDSI-$1"
})

table.insert(config.hyperlink_rules, {
    regex = [=[["' ](\w[-\w]+\/[-\w\.]+)["' ]]=],
    format = "https://www.github.com/$1",
    highlight = 1
})

return config
