return {
	{
		"folke/snacks.nvim",
		---@type snacks.Config
		opts = {
			bigfile = {},
			indent = {
				animate = {
					enabled = true,
					style = "out",
					easing = "linear",
					duration = {
						step = 50, -- ms per step
						total = 150, -- maximum duration
					},
				},
			},
		},
	},
}
