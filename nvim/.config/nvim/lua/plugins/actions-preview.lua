return {
	{
		"aznhe21/actions-preview.nvim",
		config = function()
			vim.keymap.set(
				{ "v", "n" },
				"ca",
				require("actions-preview").code_actions,
				{ desc = "List code [A]ctions" }
			)
		end,
	},
}
