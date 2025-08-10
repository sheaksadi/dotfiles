local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local c = ls.choice_node
local pluralize = require("utils.pluralize")

function extract_last_word(word)
	if type(word) ~= "string" or word == "" then
		return ""
	end

	local snake_match = string.match(word, ".*_([^_]+)$")
	if snake_match then
		return snake_match
	end

	local camel_match = string.match(word, ".*[a-z]([A-Z].*)$")
	if camel_match then
		return string.lower(camel_match)
	end

	return word
end

local function singular_dynamic(args)
	local plural = args[1][1] or ""

	local base = ""
	local word_to_singularize = plural

	local matched_base, last_word = string.match(plural, "(.*[.])([^.]+)$")

	if matched_base then
		base = matched_base -- e.g., "this.a.b."
		word_to_singularize = last_word -- e.g., "c"
	end

	local singular = pluralize.singular(word_to_singularize)
	local second_singular = pluralize.singular(extract_last_word(word_to_singularize))

	if singular == word_to_singularize then
		singular = singular .. "Val"
	end

	if second_singular == word_to_singularize then
		second_singular = singular .. "Val"
	end

	return sn(nil, { c(1, { i(1, singular), i(1, second_singular) }), t(" of ") })
end

local forof = {
	t("for (const "),
	c(1, {
		sn(1, { d(2, singular_dynamic, { 1 }), i(1, "items") }),
		sn(1, { t("["), i(2, "key"), t(", "), i(3, "val"), t("] of Object.entries("), i(1, "items"), t(")") }),
	}),
	t({ ") {", "\t" }),
	i(0),
	t({ "", "}" }),
}

local function get_loop_variable()
	local loop_vars = { "i", "j", "k", "l", "m", "n" }
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local nest_level = 0
	for l = row - 1, 0, -1 do
		local line_content = lines[l + 1]
		if line_content then
			if line_content:match("for%s*%(") or line_content:match("while%s*%(") then
				nest_level = nest_level + 1
			end
			if line_content:match("^%s*}") then
				nest_level = nest_level - 1
			end
		end
	end
	if nest_level < 0 then
		nest_level = 0
	end
	return sn(nil, i(1, loop_vars[nest_level + 1] or "i"))
end

local function copy_node_text(args)
	return args[1] or ""
end

local fori = {
	t("for (let "),
	d(2, get_loop_variable, {}),
	t(" = 0; "),
	f(copy_node_text, { 2 }),
	t(" < "),
	i(1, "length"),
	t("; "),
	f(copy_node_text, { 2 }),
	t("++) {"),
	t({ "", "\t" }),
	i(0),
	t({ "", "}" }),
}
local forir = {
	t("for (let "),
	d(2, get_loop_variable, {}),
	t(" = "),
	i(1, "length"),
	t(" - 1; "),
	f(copy_node_text, { 2 }),
	t(" >= 0; "),
	f(copy_node_text, { 2 }),
	t("--) {"),
	t({ "", "\t" }),
	i(0),
	t({ "", "}" }),
}
local if_body = {
	t("if ("),
	i(1, "condition"), -- Placeholder for the condition
	t({ ") {", "\t" }),
	i(0), -- Final cursor position inside the body
	t({ "", "}" }),
}

local ife = {
	t("if ("),
	i(1, "condition"), -- Placeholder for the condition
	t({ ") {", "\t" }),
	i(2), -- Cursor position inside the 'if' body
	t({ "", "} else {", "\t" }),
	i(0), -- Final cursor position inside the 'else' body
	t({ "", "}" }),
}
local imp = {
	t("import "),
	d(2, function(args)
		local path = args[1][1] or ""
		if not string.find(path, "/") then
			return sn(nil, i(1, path))
		else
			return sn(nil, { t("{ "), i(1), t(" }") })
		end
	end, { 1 }),
	t(' from "'),
	i(1, "module"),
	t('";'),
	i(0),
}
local function create_log_label(args)
	local text = args[1][1] or ""
	return sn(nil, { t('"'), i(1, text), t(': ", ') })
end

local cl_body = {
	t("console.log("),
	c(1, {
		i(1, ""),
		sn(nil, { d(2, create_log_label, { 1 }), i(1, "value") }),
	}),
	t(");"),
}
local class_body = {
	t("class "),
	i(1, "ClassName"),
	t({ " {", "\t" }),
	t("constructor() {"),
	t({ "", "\t\t" }),
	i(2),
	t({ "", "\t" }),
	t("}"),
	t({ "", "" }),
	i(0),
	t({ "", "}" }),
}
local is_in_class_treesitter = function()
	-- Safely check if the Tree-sitter module is available
	local ts_ok, ts = pcall(require, "vim.treesitter")
	if not ts_ok then
		return false
	end

	-- Get the parser for the current buffer.
	local parser = ts.get_parser()
	if not parser then
		return false
	end

	-- Get the syntax tree that Tree-sitter is maintaining.
	local tree = parser:trees()[1]
	if not tree then
		return false
	end

	-- Find the node at the current cursor position
	local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
	local current_node = tree:root():descendant_for_range(cursor_row - 1, cursor_col, cursor_row - 1, cursor_col)
	if not current_node then
		return false
	end

	-- Traverse up the tree from the cursor's position, checking each parent node.
	while current_node do
		local node_type = current_node:type()
		-- These node types are used by JS/TS grammars for class definitions.
		if node_type == "class_body" or node_type == "class_declaration" or node_type == "class" then
			return true
		end
		current_node = current_node:parent()
	end

	return false
end
local async_func_body = {
	-- This dynamic node ONLY builds the function signature.
	d(1, function()
		local ft = vim.bo.filetype
		local is_ts = (ft == "typescript" or ft == "typescriptreact" or ft == "vue")
		local in_class = is_in_class_treesitter()

		local signature_body
		if is_ts then
			if in_class then
				signature_body = {
					t("async "),
					i(1, "methodName"),
					t("("),
					c(2, {
						sn(nil, { i(1, "args"), t(": "), i(2, "any") }),
						t(""),
					}),
					t("): Promise<"),
					i(3, "void"),
					t(">"),
				}
			else
				signature_body = {
					t("async function "),
					i(1, "functionName"),
					t("("),
					c(2, {
						sn(nil, { i(1, "args"), t(": "), i(2, "any") }),
						t(""),
					}),
					t("): Promise<"),
					i(3, "void"),
					t(">"),
				}
			end
		else
			if in_class then
				signature_body = {
					t("async "),
					i(1, "methodName"),
					t("("),
					c(2, { i(1, "args"), t("") }),
					t(")"),
				}
			else
				signature_body = {
					t("async function "),
					i(1, "functionName"),
					t("("),
					c(2, { i(1, "args"), t("") }),
					t(")"),
				}
			end
		end
		-- The jump indices inside the choiceNode `c(2,...)` above are RELATIVE to that choice.
		-- They do not conflict with the outer i(1) and i(3) because they live inside a different node.
		return sn(nil, signature_body)
	end, {}),

	-- These static nodes build the function body.
	t(" {"),
	t({ "", "\t" }),
	i(0), -- Final cursor position.
	t({ "", "}" }),
}

local func_body = {
	-- This dynamic node ONLY builds the function signature.
	d(1, function()
		local ft = vim.bo.filetype
		local is_ts = (ft == "typescript" or ft == "typescriptreact" or ft == "vue")
		local in_class = is_in_class_treesitter()

		local signature_body
		if is_ts then
			if in_class then
				signature_body = {
					i(1, "methodName"),
					t("("),
					c(2, {
						sn(nil, { i(1, "args"), t(": "), i(2, "any") }),
						t(""),
					}),
					t("): "),
					i(3, "void"),
				}
			else
				signature_body = {
					t("function "),
					i(1, "functionName"),
					t("("),
					c(2, {
						sn(nil, { i(1, "args"), t(": "), i(2, "any") }),
						t(""),
					}),
					t("): "),
					i(3, "void"),
				}
			end
		else
			if in_class then
				signature_body = {
					i(1, "methodName"),
					t("("),
					c(2, { i(1, "args"), t("") }),
					t(")"),
				}
			else
				signature_body = {
					t("function "),
					i(1, "functionName"),
					t("("),
					c(2, { i(1, "args"), t("") }),
					t(")"),
				}
			end
		end
		-- The jump indices inside the choiceNode `c(2,...)` above are RELATIVE to that choice.
		-- They do not conflict with the outer i(1) and i(3) because they live inside a different node.
		return sn(nil, signature_body)
	end, {}),

	-- These static nodes build the function body.
	t(" {"),
	t({ "", "\t" }),
	i(0), -- Final cursor position.
	t({ "", "}" }),
}

local function is_in_parens()
	-- Get the current line and cursor column
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line_content = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""

	-- Get the text on the line up to the cursor's position
	local text_before_cursor = line_content:sub(1, col)

	-- Trim any trailing whitespace from the text before the cursor
	local trimmed_text_before = text_before_cursor:gsub("%s*$", "")

	-- Return true ONLY if the last non-whitespace character is an open parenthesis.
	-- This is a much more reliable way to detect if we are starting a
	-- new function call or inline arrow function.
	return trimmed_text_before:sub(-1) == "("
end
local alfun = {
	-- This dynamic node ONLY builds the signature before the "=>".
	d(1, function()
		local ft = vim.bo.filetype
		local is_ts = (ft == "typescript" or ft == "typescriptreact" or ft == "vue")
		local in_parens = is_in_parens()

		local signature_body
		if is_ts then
			-- TypeScript versions
			if in_parens then
				-- Inline callback signature WITH return type
				signature_body = {
					t("async ("),
					c(1, { sn(nil, { i(1, "args"), t(": "), i(2, "any") }), t("") }),
					t(")"),
				}
			else
				-- Full const declaration signature with a better default return type
				signature_body = {
					t("const "),
					i(1, "functionName"),
					t(" = async ("),
					c(2, { sn(nil, { i(1, "args"), t(": "), i(2, "any") }), t("") }),
					t("): Promise<"),
					i(3, "void"),
					t(">"),
				}
			end
		else
			-- JavaScript versions
			if in_parens then
				-- Inline callback signature: (args)
				signature_body = {
					t("async ("),
					c(1, { i(1, "args"), t("") }),
					t(")"),
				}
			else
				-- Full const declaration signature
				signature_body = {
					t("const "),
					i(1, "functionName"),
					t(" = async ("),
					c(2, { i(1, "args"), t("") }),
					t(")"),
				}
			end
		end

		return sn(nil, signature_body)
	end, {}),

	-- These static nodes build the arrow, body, and return statement.
	t(" => {"),
	t({ "", "\t" }),
	t("return "),
	i(0), -- The final cursor position is now correctly placed after "return ".
	t({ "", "}" }),
}

local lfun = {
	-- This dynamic node ONLY builds the signature before the "=>".
	d(1, function()
		local ft = vim.bo.filetype
		local is_ts = (ft == "typescript" or ft == "typescriptreact" or ft == "vue")
		local in_parens = is_in_parens()

		local signature_body
		if is_ts then
			-- TypeScript versions
			if in_parens then
				-- Inline callback signature WITH return type
				signature_body = {
					t("("),
					c(1, { sn(nil, { i(1, "args"), t(": "), i(2, "any") }), t("") }),
					t(")"),
				}
			else
				-- Full const declaration signature with a better default return type
				signature_body = {
					t("const "),
					i(1, "functionName"),
					t(" = ("),
					c(2, { sn(nil, { i(1, "args"), t(": "), i(2, "any") }), t("") }),
					t("): "),
					i(3, "void"),
				}
			end
		else
			-- JavaScript versions
			if in_parens then
				-- Inline callback signature: (args)
				signature_body = {
					t("("),
					c(1, { i(1, "args"), t("") }),
					t(")"),
				}
			else
				-- Full const declaration signature
				signature_body = {
					t("const "),
					i(1, "functionName"),
					t(" = ("),
					c(2, { i(1, "args"), t("") }),
					t(")"),
				}
			end
		end

		return sn(nil, signature_body)
	end, {}),

	-- These static nodes build the arrow, body, and return statement.
	t(" => {"),
	t({ "", "\t" }),
	t("return "),
	i(0), -- The final cursor position is now correctly placed after "return ".
	t({ "", "}" }),
}
local try_catch = {
	t("try {"),
	t({ "", "\t" }),
	i(2),
	t({ "", "} catch (" }),
	i(1, "error"), -- Editable error name
	t({ ") {", "\t" }),
	i(0),
	t({ "", "}" }),
}

-- 2. try...finally block
local try_finally = {
	t("try {"),
	t({ "", "\t" }),
	i(1),
	t({ "", "} finally {", "\t" }),
	i(0),
	t({ "", "}" }),
}

-- 3. try...catch...finally block
local try_catch_finally = {
	t("try {"),
	t({ "", "\t" }),
	i(2),
	t({ "", "} catch (" }),
	i(1, "error"), -- Editable error name
	t({ ") {", "\t" }),
	i(3),
	t({ "", "} finally {", "\t" }),
	i(0),
	t({ "", "}" }),
}

-- 4. setTimeout function
local set_timeout = {
	t("setTimeout(() => {"),
	t({ "", "\t" }),
	i(1),
	t({ "", "}, " }),
	i(2, "1000"),
	t(");"),
	i(0),
}

-- 5. setInterval function
local set_interval = {
	t("setInterval(() => {"),
	t({ "", "\t" }),
	i(1),
	t({ "", "}, " }),
	i(2, "1000"),
	t(");"),
	i(0),
}

-- 6. Promise creation
local new_promise = {
	t("new Promise((resolve, reject) => {"),
	t({ "", "\t" }),
	i(1),
	t({ "", "});" }),
	i(0),
}

-- 7. async/await fetch
local async_fetch = {
	t("async function "),
	i(1, "getData"),
	t("("),
	i(2),
	t(")"),
	-- Dynamically add return type for TS
	d(3, function()
		local ft = vim.bo.filetype
		if ft == "typescript" or ft == "typescriptreact" or ft == "vue" then
			return sn(nil, t(": Promise<void>"))
		else
			return sn(nil, t(""))
		end
	end, {}),
	t({ " {", "\t" }),
	t("try {"),
	t({ "", "\t\t" }),
	t("const response = await fetch("),
	i(4, "url"),
	t({ ");", "\t\t" }),
	t("const data = await response.json();"),
	t({ "", "\t\t" }),
	i(5),
	t({ "", "\t} catch (" }),
	i(6, "error"), -- Editable error name
	t({ ") {", "\t\t" }),
	t("console.error("),
	i(0),
	t({ ");", "\t}" }),
	t({ "", "}" }),
}

-- TypeScript 'type' alias
local type_alias = {
	t("type "),
	i(1, "Name"),
	t(" = "),
	i(0),
	t(";"),
}

local jsSnippets = {
	s("fo", forof),
	s("for", forof),
	s("fori", fori),

	s("forir", forir),
	s("if", if_body),
	s("ife", ife),
	s("imp", imp),
	s("cl", cl_body),
	s("log", cl_body),
	s("cls", class_body),
	s("func", func_body),
	s("afunc", async_func_body),
	s("funl", lfun),
	s("afunl", alfun),

	s("try", try_catch),
	s("tryf", try_finally),
	s("trycf", try_catch_finally),
	s("sto", set_timeout),
	s("siv", set_interval),
	s("prom", new_promise),
	s("fetch", async_fetch),
	s("type", type_alias),
}
ls.add_snippets("javascript", jsSnippets)
ls.add_snippets("typescript", jsSnippets)

local vue_snippets = {
	s(
		"vbase",
		fmt(
			[[
<script setup lang="ts">
{}
</script>

<template>
  {}
</template>

<style scoped>
{}
</style>
]],
			{ i(1), i(2), i(3) }
		)
	),
}
local all_vue_snippets = {}
for _, snippet in ipairs(jsSnippets) do
	table.insert(all_vue_snippets, snippet)
end
for _, snippet in ipairs(vue_snippets) do
	table.insert(all_vue_snippets, snippet)
end

ls.add_snippets("vue", all_vue_snippets)
