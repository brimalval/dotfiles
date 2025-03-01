return {
  "kiyoon/jupynium.nvim",
  build = "pip3 install --user .",
  -- build = "conda run --no-capture-output -n jupynium pip install .",
  -- enabled = vim.fn.isdirectory(vim.fn.expand "~/miniconda3/envs/jupynium"),
  use_default_keybindings = false,
  config = function()
    local map = vim.keymap.set
    map(
      { "n", "x" },
      "<Leader>jx",
      "<cmd>JupyniumExecuteSelectedCells<CR>",
      { desc = "Jupynium execute selected cells" }
    )
    map(
      { "n", "x" },
      "<Leader>jc",
      "<cmd>JupyniumClearSelectedCellsOutputs<CR>",
      { desc = "Jupynium clear selected cells outputs" }
    )
    map({ "n", "x" }, "<Leader>jk", "<cmd>JupyniumKernelHover<CR>", { desc = "Jupynium hover (inspect a variable)" })
  end,
}
