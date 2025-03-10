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

		local function http_snippet(method)
			return snippet(method, {
				text(method .. " "),
				insert(1, "/your-endpoint"),
				text({ " HTTP/1.1", "" }),
				text("Host: "),
				insert(2, "example.com"),
				text({ "", "" }),
				text("Headers:"),
				text({ "", "" }),
				insert(3, "Content-Type: application/json"),
				text({ "", "" }),
				text({ "", "Body:" }),
				text({ "", "" }),
				insert(4, "{}"),
			})
		end
		-- Markdown snippets
		ls.add_snippets("markdown", {
			snippet("bwarn", blocktext("WARNING")),
			snippet("bdanger", blocktext("DANGER")),
			snippet("bnote", blocktext("NOTE")),
			snippet("bimportant", blocktext("IMPORTANT")),
		})

		local http_snippets = {
			http_snippet("GET"),
			http_snippet("POST"),
			http_snippet("PUT"),
			http_snippet("DELETE"),
			http_snippet("PATCH"),
		}

		ls.add_snippets("http", http_snippets)
		ls.add_snippets("rest", http_snippets)

		ls.setup({})
	end,
}
