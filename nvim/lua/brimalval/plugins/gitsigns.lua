return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },

	opts = {
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
			end

			-- Navigation
			map("n", "]h", gs.next_hunk, "Next Hunk")
			map("n", "[h", gs.prev_hunk, "Prev Hunk")

			-- Actions
			map("n", "<leader>gh", "", "Git hunk operations")
			map("n", "<leader>ghs", gs.stage_hunk, "Stage hunk")
			map("n", "<leader>ghr", gs.reset_hunk, "Reset hunk")
			map("v", "<leader>ghs", function()
				gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Stage hunk")
			map("v", "<leader>ghr", function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Reset hunk")

			map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
			map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")

			map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")

			map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")

			map("n", "<leader>ghb", function()
				gs.blame_line({ full = true })
			end, "Blame line")
			map("n", "<leader>ghB", gs.toggle_current_line_blame, "Toggle line blame")

			map("n", "<leader>ghd", gs.diffthis, "Diff this")
			map("n", "<leader>ghD", function()
				gs.diffthis("~")
			end, "Diff this ~")

			-- Text object
			map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
		end,
	},
}
