local plugins = {
	{ "tpope/vim-repeat", lazy = false },
	{ "tpope/vim-surround", lazy = false },
	{ "tpope/vim-sensible", lazy = false },
	{ "pocco81/auto-save.nvim", lazy = false },
	{ "terrastruct/d2-vim", ft = "d2" },
	{
		"nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    cmd = { "TSInstall", "TSUninstall", "TSUpdate", "TSUpdateSync" },
	version = "*", -- latest stable version
		opts = {
			ensure_installed = {
				"bash",
				"javascript",
				"java",
				"json",
				"jq",
				"regex",
				"tsx",
				"typescript",
				"vim",
				"yaml",
				"kotlin",
        "vimdoc",
        "query"
			},
		},
	},
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"prettier",
     		"bash-language-server",
				"shellcheck",
				"stylua",
				"jq-lsp"
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"jose-elias-alvarez/null-ls.nvim",
			config = function()
				require("custom.configs.null-ls")
			end,
		},
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end,
	}, 
}

return plugins
