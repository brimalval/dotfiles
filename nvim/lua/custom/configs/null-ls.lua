local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require('null-ls')

local python_executable = io.popen('which python'):read('*line')

local sources = {
  null_ls.builtins.formatting.black.with({
    extra_args = { "-l", "80" },
  }),
  null_ls.builtins.formatting.isort,
  null_ls.builtins.diagnostics.flake8,
  null_ls.builtins.diagnostics.mypy.with({
    extra_args = function(params)
        return python_executable and {
            "--python-executable",
            python_executable,
        }
    end,
  }),
  null_ls.builtins.diagnostics.ruff,
}

local opts = {
  sources = sources,
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({
        group = augroup,
        buffer = bufnr,
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
}
return opts
