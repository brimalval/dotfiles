return {
	{
		"kndndrj/nvim-dbee",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		build = function()
			-- Install tries to automatically detect the install method.
			-- if it fails, try calling it with one of these parameters:
			--    "curl", "wget", "bitsadmin", "go"
			require("dbee").install()
		end,
		config = function()
			require("dbee").setup(--[[optional config]])
		end,
	},
	-- {
	-- 	"hrsh7th/nvim-cmp",
	-- 	version = false, -- last release is way too old
	-- 	event = "InsertEnter",
	-- 	ft = { "sql" },
	-- 	dependencies = {
	-- 		"hrsh7th/cmp-nvim-lsp",
	-- 		"hrsh7th/cmp-buffer",
	-- 		"hrsh7th/cmp-path",
	-- 		{
	-- 			"MattiasMTS/cmp-dbee",
	-- 			dependencies = {
	-- 				{ "kndndrj/nvim-dbee" },
	-- 			},
	-- 			ft = "sql", -- optional but good to have
	-- 			opts = {}, -- needed
	-- 		},
	-- 	},
	-- 	opts = function()
	-- 		vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
	-- 		local cmp = require("cmp")
	-- 		local defaults = require("cmp.config.default")()
	-- 		local auto_select = true
	-- 		return {
	-- 			auto_brackets = {}, -- configure any filetype to auto add brackets
	-- 			completion = {
	-- 				completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
	-- 			},
	-- 			preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
	-- 			mapping = cmp.mapping.preset.insert({
	-- 				["<C-b>"] = cmp.mapping.scroll_docs(-4),
	-- 				["<C-f>"] = cmp.mapping.scroll_docs(4),
	-- 				["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
	-- 				["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
	-- 				["<C-Space>"] = cmp.mapping.complete(),
	-- 				["<C-CR>"] = function(fallback)
	-- 					cmp.abort()
	-- 					fallback()
	-- 				end,
	-- 			}),
	-- 			sources = cmp.config.sources({
	-- 				{ name = "nvim_lsp" },
	-- 				{ name = "path" },
	-- 			}, {
	-- 				{ name = "buffer" },
	-- 			}, {
	-- 				{ name = "cmp-dbee" },
	-- 			}),
	-- 			experimental = {
	-- 				-- only show ghost text when we show ai completions
	-- 				ghost_text = vim.g.ai_cmp and {
	-- 					hl_group = "CmpGhostText",
	-- 				} or false,
	-- 			},
	-- 			sorting = defaults.sorting,
	-- 		}
	-- 	end,
	-- },
}
