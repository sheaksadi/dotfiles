local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local c = ls.choice_node

local checkbox = {
	t("- [ ] "),
	i(0, ""),
}
local codeBlock = {
	t("```"),
	i(1, "lang"),
	t({ "", "" }),
	i(0),
	t({ "", "```" }),
}

local mkSnip = {
	s("check", checkbox),
	s("co", codeBlock),
}
ls.add_snippets("markdown", mkSnip)
