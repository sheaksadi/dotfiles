return {
	{
		"folke/snacks.nvim",
		keys = {
			{
				"<leader>e",
				function()
					Snacks.explorer()
				end,
				desc = "File Explorer",
			},
		},
		opts = {
			explorer = {
				-- Show hidden files/dotfiles
				filters = {
					dotfiles = false, -- Set to false to SHOW dotfiles
					custom = {}, -- Add any additional custom filters if needed
				},

				-- Floating window configuration
				view = {
					float = {
						enable = true,
						open_win_config = {
							relative = "editor",
							width = 80, -- Columns (absolute number)
							height = 30, -- Lines (absolute number)
							border = "rounded",
							row = 1, -- Position from top
							col = 1, -- Position from left
						},
					},
				},

				-- Start closed by default
				auto_open = false,
			},
		},
	},
}
