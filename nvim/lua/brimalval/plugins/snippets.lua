return {
	"L3mon4D3/LuaSnip",
	version = "v2.*",
	build = "make install_jsregexp",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local ls = require("luasnip")
		local snippet = ls.snippet
		local text = ls.text_node
		local insert = ls.insert_node

		local function blocktext(title)
			return {
				text({ "> [!" .. title .. "]", "" }),
				text("> "),
				insert(0),
			}
		end

		-- Markdown snippets
		ls.add_snippets("markdown", {
			snippet("bwarn", blocktext("WARNING")),
			snippet("bdanger", blocktext("DANGER")),
			snippet("bnote", blocktext("NOTE")),
			snippet("bimportant", blocktext("IMPORTANT")),
		})

		ls.setup({})
	end,
}
