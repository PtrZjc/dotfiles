local present, null_ls = pcall(require, "null-ls")

if not present then
   return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
local b = null_ls.builtins

local sources = {
   b.formatting.ktlint,
   b.formatting.prettier,
   b.formatting.beautysh,
   b.formatting.stylua,
   b.formatting.autopep8,
   b.diagnostics.shellcheck,
}

null_ls.setup {
   debug = true,
   sources = sources,
}
