local M = {}

M.setup = function()
	local set_hl = vim.api.nvim_set_hl

	-- Example: Customize visual mode
	set_hl(0, "Visual", { bg = "#575279" })

	-- Make diff text invisible
	set_hl(0, "DiffDelete", { bg = "#4B3148", fg = "#4B3148" })
end

M.setup()

return M
