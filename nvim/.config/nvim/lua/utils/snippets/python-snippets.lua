local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

ls.add_snippets("python", {
	s("def", {
		t("def "),
		i(1, "function_name"),
		t("("),
		i(2, "args"),
		t("):"),
		t({ "", "    " }),
		i(0),
	}),
	s("class", {
		t("class "),
		i(1, "ClassName"),
		t(":"),
		t({ "", "    def __init__(self" }),
		i(2, ", args"),
		t("):"),
		t({ "", "        " }),
		i(0),
	}),
	s("if", {
		t("if "),
		i(1, "condition"),
		t(":"),
		t({ "", "    " }),
		i(0),
	}),
	s("for", {
		t("for "),
		i(1, "item"),
		t(" in "),
		i(2, "iterable"),
		t(":"),
		t({ "", "    " }),
		i(0),
	}),
	s("try", {
		t({ "try:", "    " }),
		i(1, "pass"),
		t({ "", "except " }),
		i(2, "Exception"),
		t({ " as e:", "    " }),
		i(0, "pass"),
	}),
	s("main", {
		t({ 'if __name__ == "__main__":', "    " }),
		i(0),
	}),
	s("doc", {
		t({ '"""', "" }),
		i(1, "Description"),
		t({ "", "", "Args:", "    " }),
		i(2, "arg: Description"),
		t({ "", "", "Returns:", "    " }),
		i(3, "Return description"),
		t({ "", '"""' }),
	}),
	s("print", {
		t('print(f"'),
		i(1),
		t('")'),
	}),
})
