local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node
local isn = ls.indent_snippet_node

-- clear snippets so the file can be re-loaded
require("luasnip.session.snippet_collection").clear_snippets("python")

local dataclass = s({
	trig = "data",
	dscr = "Python dataclass boilerplate",
	wordTrig = false,
}, {
	t("@dataclass"),
	t({ "", "class " }),
	i(1, "ClassName"), -- Jump point 1: Class name
	t(":"),
	t({ "", "\t" }),
	i(2), -- Jump point 2: Attributes
	t({ "", "" }),
	i(0), -- Final jump point
})

ls.add_snippets("python", {
	dataclass,
})
