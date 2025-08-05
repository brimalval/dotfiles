local function augroup(name)
	return vim.api.nvim_create_augroup("brimalval_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

-- Create directory if it doesn't exist upon save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Show diagnostics on cursor hold
-- Used in conjunction with setting updatetime to 100
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		local line = vim.api.nvim_win_get_cursor(0)[1] - 1
		local buf = vim.api.nvim_get_current_buf()
		local diagnostics = vim.diagnostic.get(buf, { lnum = line })
		if #diagnostics > 0 then
			vim.diagnostic.open_float(nil, {
				focusable = false,
				border = "rounded",
				scope = "cursor",
			})
		end
	end,
})
