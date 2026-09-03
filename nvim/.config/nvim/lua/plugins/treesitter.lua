return {

	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			install_dir = vim.fn.stdpath("data") .. "/site",
		},
		config = function(_, opts)
			require("nvim-treesitter").setup(opts)

			-- Install the parsers we use (no-op if already installed).
			require("nvim-treesitter").install({
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
				"go",
				"typescript",
				"python",
				"java",
			})

			-- Enable highlighting + indentation for filetypes that have a parser.
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					if vim.bo.filetype == "" then
						return
					end
					if not pcall(vim.treesitter.language.add, vim.bo.filetype) then
						return
					end
					pcall(vim.treesitter.start)
					if pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf()) then
						vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
}
