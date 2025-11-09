local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node
local isn = ls.indent_snippet_node

local same = function(index)
	return f(function(arg)
		return arg[1][1]
	end, { index })
end

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

local selfdot = s({
	trig = "self",
	dscr = "Python self initialization",
	wordTrig = false,
}, {
	t("self."),
	i(1, "attr"),
	t(" = "),
	same(1),
	t({ "", "self" }),
	i(0),
})

local HERE = s({
	trig = "HERE",
	dscr = "Directory of file",
}, {
	t({ "from pathlib import Path", "", "" }),
	t({ "HERE = Path(__file__).parent", "" }),
	t({ "HOME = Path.home()", "" }),
	i(0),
})

local installer = s({
	trig = "install",
	dscr = "installman installer",
}, {
	t({ "from argparse import ArgumentParser, Namespace", "" }),
	t({ "from installman import installer", "" }),
	t({ "from pathlib import Path", "", "", "" }),
	t({ "HERE = Path(__file__).parent", "" }),
	t({ "HOME = Path.home()", "", "", "" }),
	t({ '@installer("' }),
	i(1, "program"),
	t({ '")', "" }),
	t({ "def " }),
	t({ "install_" }),
	same(1),
	t({ "(args: Namespace):", "" }),
	t({ "   " }),
	i(3, "..."),
	t({ "", "", "", "" }),
	t({ "@install_" }),
	same(1),
	t({ ".parser", "" }),
	t({ "def " }),
	same(1),
	t({ "_parser(_parser: ArgumentParser):", "" }),
	t({ "   " }),
	t('_parser.add_argument("'),
	i(2, "name"),
	t({ '")', "" }),
	t({ "", "" }),
	i(0),
})

ls.add_snippets("python", {
	dataclass,
	selfdot,
	HERE,
	installer,
})
