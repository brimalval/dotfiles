return {
  -- Add the community repository of plugin specifications
  "AstroNvim/astrocommunity",
  -- example of importing a plugin, comment out to use it or add your own
  -- available plugins can be found at https://github.com/AstroNvim/astrocommunity

  -- { import = "astrocommunity.colorscheme.catppuccin" },
  -- { import = "astrocommunity.completion.copilot-lua-cmp" },
  -- { import = "astrocommunity.workflow.hardtime-nvim" },
  { import = "astrocommunity.bars-and-lines.heirline-vscode-winbar" },
  { import = "astrocommunity.bars-and-lines.vim-illuminate" },
  {
    import = "astrocommunity.completion.codeium-vim",
    config = function()
      -- Unbind all existing insert mode ctrl + K bindings
      vim.keymap.set("i", "<C-g>", "<Nop>", { silent = true })
      vim.keymap.set("i", "<C-g>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
    end,
  },
  { import = "astrocommunity.debugging.nvim-dap-repl-highlights" },
  { import = "astrocommunity.debugging.nvim-dap-virtual-text" },
  { import = "astrocommunity.debugging.telescope-dap-nvim" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.fuzzy-finder.telescope-zoxide" },
  { import = "astrocommunity.lsp.lsp-signature-nvim" },
  { import = "astrocommunity.motion.harpoon" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.typescript-all-in-one" },
  { import = "astrocommunity.test.neotest" },
  {
    import = "astrocommunity.completion.cmp-cmdline",
    config = function()
      local cmp = require "cmp"
      cmp.setup {
        mapping = {
          ["<C-space>"] = cmp.mapping.complete(),
        },
      }
    end,
  },
}
