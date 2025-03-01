local function yank_and_open(state)
  local node = state.tree:get_node()
  if node then
    local path = node:get_id()

    if node.type == "file" then
      -- Remove filename from path
      -- todo: fix for names with dashes
      path = string.gsub(path, node.name, "")
    end

    vim.cmd("!tmux new-window -c " .. path)
    return
  end
  print("No node selected")
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  opts = {
    window = {
      mappings = {
        ["T"] = { yank_and_open, desc = "Open in a new tmux window" },
      },
    },
  },
}
