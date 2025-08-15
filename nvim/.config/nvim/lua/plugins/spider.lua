return {
	{
		"chrisgrieser/nvim-spider",
		enabled = true,
		opts = {
			skipInsignificantPunctuation = false,
			consistentOperatorPending = false,
			subwordMovement = true,
			customPatterns = {},
		},
		keys = {
			{ "w", "<cmd>lua require('spider').motion('w')<CR>", mode = { "n", "o", "x" } },
			{ "e", "<cmd>lua require('spider').motion('e')<CR>", mode = { "n", "o", "x" } },
			{ "b", "<cmd>lua require('spider').motion('b')<CR>", mode = { "n", "o", "x" } },
		},
	},
}
