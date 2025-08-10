return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			vim.keymap.set("n", "<S-h>", function()
				require("bufferline").cycle(-1)
			end, { desc = "Prev buffer" })
			vim.keymap.set("n", "<S-l>", function()
				require("bufferline").cycle(1)
			end, { desc = "Next buffer" })
			vim.keymap.set("n", "<leader>bc", function()
				vim.cmd("w")
				vim.cmd("bdelete!")
			end, { desc = "Close current buffer" })
			vim.keymap.set("n", "<C-z>", function()
				vim.cmd("w")
				vim.cmd("bdelete!")
			end, { desc = "Close current buffer" })
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
	},
}

