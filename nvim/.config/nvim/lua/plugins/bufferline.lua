return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("bufferline").setup({
			options = {
				separator_style = "thin",
				show_buffer_close_icons = false,
				show_close_icon = false,
				modified_icon = "●",
				diagnostics = "nvim_lsp",
				always_show_bufferline = false,
			},
		})
	end,
}