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

local function singular_dynamic(args)
	local plural = args[1][1]

	local new_plural, count = string.gsub(plural, "this.", "")

	local singular = pluralize.singular(new_plural)

	if singular == new_plural then
		singular = singular .. "_val"
	end

	return sn(nil, i(1, singular))
end

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

local forof = {
	t("for (const "),
	d(2, singular_dynamic, { 1 }), -- Editable singular from plural
	t(" of "),
	i(1, "items"), -- User types plural here
	t({ ") {", "\t" }), -- Use a tab for indentation
	i(0),
	t({ "", "}" }),
}
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
	return sn(nil, t('"' .. text .. ': ", '))
end

local cl_body = {
	t("console.log("),
	d(2, create_log_label, { 1 }),
	i(1, "value"),
	t(");"),
	i(0),
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

	-- Get only the text on the line before the cursor
	local text_before_cursor = line_content:sub(1, col)

	-- A simple heuristic: if there are more open parens than closed ones
	-- before the cursor, we are likely inside a function call.
	local open_count = select(2, text_before_cursor:gsub("%(", ""))
	local close_count = select(2, text_before_cursor:gsub("%)", ""))

	return open_count > close_count
end
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
					t("): "),
					i(2, "void"), -- Added the missing return type placeholder
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

local jsSnippets = {
	s("fo", forof),
	s("for", forof),
	s("fori", fori),

	s("forir", forir),
	s("if", if_body),
	s("ife", ife),
	s("imp", imp),
	s("cl", cl_body),
	s("cls", class_body),
	s("func", func_body),
	s("funl", lfun),
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
