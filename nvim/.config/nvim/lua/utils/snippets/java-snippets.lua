local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

ls.add_snippets("java", {
	s("class", {
		t("public class "),
		i(1, "ClassName"),
		t({ " {", "    " }),
		i(0),
		t({ "", "}" }),
	}),
	s("main", {
		t({ "public static void main(String[] args) {", "    " }),
		i(0),
		t({ "", "}" }),
	}),
	s("sout", {
		t('System.out.println('),
		i(1),
		t(");"),
	}),
	s("psvm", {
		t({ "public static void main(String[] args) {", "    " }),
		i(0),
		t({ "", "}" }),
	}),
	s("method", {
		t("public "),
		i(1, "void"),
		t(" "),
		i(2, "methodName"),
		t("("),
		i(3),
		t({ ") {", "    " }),
		i(0),
		t({ "", "}" }),
	}),
	s("for", {
		t("for (int "),
		i(1, "i"),
		t(" = 0; "),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t(" < "),
		i(2, "n"),
		t("; "),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t({ "++) {", "    " }),
		i(0),
		t({ "", "}" }),
	}),
	s("foreach", {
		t("for ("),
		i(1, "Type"),
		t(" "),
		i(2, "item"),
		t(" : "),
		i(3, "collection"),
		t({ ") {", "    " }),
		i(0),
		t({ "", "}" }),
	}),
	s("if", {
		t("if ("),
		i(1, "condition"),
		t({ ") {", "    " }),
		i(0),
		t({ "", "}" }),
	}),
	s("try", {
		t({ "try {", "    " }),
		i(1),
		t({ "", "} catch (" }),
		i(2, "Exception"),
		t(" "),
		i(3, "e"),
		t({ ") {", "    " }),
		i(0),
		t({ "", "}" }),
	}),
	s("test", {
		t({ "@Test", "public void " }),
		i(1, "testMethod"),
		t({ "() {", "    " }),
		i(0),
		t({ "", "}" }),
	}),
})
