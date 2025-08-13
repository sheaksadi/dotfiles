return {
	{
		"dkarter/bullets.vim",
		ft = { "markdown", "text", "gitcommit" },
		config = function()
			vim.g.bullets_enabled_file_types = { "markdown", "text", "gitcommit" }
			vim.g.bullets_checkbox_markers = " .oOX" -- progression: empty -> . -> o -> O -> X
		end,
	},
}
