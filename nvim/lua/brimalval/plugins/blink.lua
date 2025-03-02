return {
	"saghen/blink.cmp",
	dependencies = "rafamadriz/friendly-snippets",
	version = "*",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = { preset = "default" },
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 250,
				window = {
					border = vim.g.borderStyle,
					winhighlight = "Normal:Normal,FloatBorder:FloatCmpDocBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
				},
			},
			menu = {
				border = vim.g.borderStyle,
				draw = { gap = 2 },
				winhighlight = "Normal:Normal,FloatBorder:FloatCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
			},
		},
	},
	opts_extend = { "sources.default" },
}
