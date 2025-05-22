-- Basic settings
vim.opt.swapfile = false
vim.opt.compatible = false
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

vim.opt.number = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.ignorecase = true

-- Disable right mouse click
vim.keymap.set({'n', 'i'}, '<RightMouse>', '<Nop>')

-- Bootstrap lazy.nvim, copied from https://lazy.folke.io/installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo,
        lazypath
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            {"Failed to clone lazy.nvim:\n", "ErrorMsg"}, {out, "WarningMsg"},
            {"\nPress any key to exit..."}
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Plugins
require("lazy").setup({
    "tpope/vim-repeat", "tpope/vim-surround", {
        "pocco81/auto-save.nvim",
        config = function() require("auto-save").setup() end
    }, {
        "dense-analysis/ale",
        config = function()
            vim.g.ale_fixers = {
                ['*'] = {'remove_trailing_lines', 'trim_whitespace'},
                javascript = {'prettier'},
                json = {'prettier'},
                yaml = {'prettier'},
                bash = {'beautysh'}
            }
            vim.g.ale_linters = {bash = {'shellcheck'}}
            vim.g.ale_fix_on_save = 1
        end
    }, {
        "navarasu/onedark.nvim",
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require('onedark').setup {style = 'darker'}
            require('onedark').load()
        end
    }
})

