local plugins = {
  { "tpope/vim-repeat" },
  { "tpope/vim-surround" },
      { "tpope/vim-sensible" },
  { "pocco81/auto-save.nvim", lazy = false },
  { "terrastruct/d2-vim", cmd= "d2" },   -- This will lazy load the plugin when :d2 is invoked
  {
    "neovim/nvim-lspconfig",
    dependencies = {
    "jose-elias-alvarez/null-ls.nvim",
      config = function()
        require "custom.configs.null-ls"
    end,
    },
    config = function ()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end
   },
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
   {
    "williamboman/mason.nvim",
    opts = {
       ensure_installed = {
         "ktlint",
         "prettier",
         "beautysh",
         "autopep8",
         "shellcheck",
       },
     },
   },
}
return plugins
