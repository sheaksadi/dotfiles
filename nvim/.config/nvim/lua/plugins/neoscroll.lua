return {
	"karb94/neoscroll.nvim",
	config = function()
		require("neoscroll").setup({
			-- Put options here
			mappings = {
				"<C-u>",
				"<C-d>",
				"<C-b>",
				"<C-f>",
				"<C-y>",
				"<C-e>",
				"zt",
				"zz",
				"zb",
			},
			hide_cursor = false, -- Hide cursor while scrolling
			stop_eof = true, -- Stop at end of file
			respect_scrolloff = false, -- Stop at scrolloff value
			cursor_scrolls_alone = true, -- Cursor moves while scrolling
			easing_function = "sine", -- Options: quadratic, cubic, quartic, quintic, circular, sine
			-- post_hook = function()
			-- 	vim.cmd("normal! zz")
			-- end,
		})
	end,
}