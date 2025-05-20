return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("harpoon"):setup()
			-- Load the Telescope extension
			require("telescope").load_extension("harpoon")
		end,
	},
}
