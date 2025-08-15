return {
	enabled = false,
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	opts = {
		indent = {
			char = "│", -- more visible indent line like lazyvim
			-- tab_char = "│",
		},
		scope = {
			enabled = false,
			show_start = false,
			show_end = false,
			-- highlight = { "function", "label" },
		},
		exclude = {
			filetypes = {
				"help",
				"alpha",
				"dashboard",
				"neo-tree",
				"trouble",
				"trouble",
				"lazy",
				"mason",
				"notify",
				"toggleterm",
				"lazyterm",
			},
		},
	},
}
