local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("vue", {
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
			{
				i(1, "// imports"),
				i(2, "<div></div>"),
				i(3, "/* styles */"),
			}
		)
	),
})
