return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	-- keys = {
	-- 	{
	-- 		"<leader>f",
	-- 		function()
	-- 			require("conform").format({ async = true, lsp_format = "fallback" })
	-- 		end,
	-- 		mode = "",
	-- 		desc = "[F]ormat buffer",
	-- 	},
	-- },

	config = function()
		local ensure_installed = {
			"stylua",
			"shellcheck",
			"shfmt",
		}
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		require("conform").setup({

			notify_on_error = true,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				-- local disable_filetypes = { c = true, cpp = true }
				local disable_filetypes = {}
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 500,
						lsp_format = "fallback",
					}
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
				sql = { "sql-formatter" },
				sh = { "shfmt" },
				bash = { "shfmt" },
			},
			formatters = {
				["sql-formatter"] = {
					-- We are NOT using 'inherit' because the definition is missing.
					-- We provide the command to fix the PATH issue.
					command = vim.fn.stdpath("data") .. "/mason/bin/sql-formatter",
					-- We provide the args to fix the dialect parsing crash.
					args = { "--language", "postgresql" },
				},
			},
		})
	end,
}
