---@type ChadrcConfig
local M = {}

M.general = {
    n = {
        ["<C-Left>"] = { "<cmd> TmuxNavigateLeft<CR>", "window left" },
        ["<C-Right>"] = { "<cmd> TmuxNavigateRight<CR>", "window right" },
        ["<C-Down>"] = { "<cmd> TmuxNavigateDown<CR>", "window down" },
        ["<C-Up>"] = { "<cmd> TmuxNavigateUp<CR>", "window up" },
    }
}
    
return M