local plugins = {
	{ "christoomey/vim-tmux-navigator", lazy = false },
	{ "tpope/vim-repeat", lazy = false },
	{ "tpope/vim-surround", lazy = false },
	{ "tpope/vim-sensible", lazy = false },
	{ "pocco81/auto-save.nvim", lazy = false },
	{ "terrastruct/d2-vim" },
	{
		"nvim-treesitter/nvim-treesitter",
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
			},
		},
	},
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"ktlint",
				"prettier",
				"beautysh",
        "bash-language-server",
				"autopep8",
				"shellcheck",
				"stylua",
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
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		opts = {
			-- https://github.com/zbirenbaum/copilot.lua#setup-and-configuration
			suggestion = {
			  auto_trigger = false,
			},
			keymap = {
				accept = "<M-\\>",
			  },
		  },
	},
  
}

return plugins
