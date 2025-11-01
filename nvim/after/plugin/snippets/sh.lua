local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node
local isn = ls.indent_snippet_node

-- clear snippets so the file can be re-loaded
require("luasnip.session.snippet_collection").clear_snippets("sh")

ls.add_snippets("sh", {
	s("for", {
		t("for "),
		i(1, "item"),
		t(" in "),
		i(2, "list"),
		-- hard coding 4 spaces, can't figure out isn
		t({ "; do", "    " }),
		i(3, "text"),
		-- extra new line after the "done"
		t({ "", "done", "", "" }),
		i(0),
	}),
})
