-- Diagnostic Config
-- See :help vim.diagnostic.Opts
vim.diagnostic.config({
	-- virtual_lines = true,

	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	} or {},
	virtual_text = {
		source = "if_many",
		spacing = 2,
		format = function(diagnostic)
			local diagnostic_message = {
				[vim.diagnostic.severity.ERROR] = diagnostic.message,
				[vim.diagnostic.severity.WARN] = diagnostic.message,
				[vim.diagnostic.severity.INFO] = diagnostic.message,
				[vim.diagnostic.severity.HINT] = diagnostic.message,
			}
			return diagnostic_message[diagnostic.severity]
		end,
	},
})

vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })
vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" })
-- Only target diagnostic virtual text highlights
local virt_text_groups = {
	"DiagnosticVirtualTextError",
	"DiagnosticVirtualTextWarn",
	"DiagnosticVirtualTextInfo",
	"DiagnosticVirtualTextHint",
	"DiagnosticVirtualTextOk", -- If exists
	-- "LspInlayHint",
}
for _, group in ipairs(virt_text_groups) do
	local fg = vim.api.nvim_get_hl(0, { name = group }).fg
	vim.api.nvim_set_hl(0, group, { fg = fg })
end

vim.api.nvim_set_hl(0, "LspInlayHint", {
	fg = "#7d7d7d", -- Medium gray color
	bg = "none", -- No background
	italic = true, -- Slight emphasis
})

vim.api.nvim_set_hl(0, "LspInlayHintParameter", {
	fg = "#5d7d9d", -- Soft blue
	bg = "none",
	italic = true,
})

vim.api.nvim_set_hl(0, "LspInlayHintType", {
	fg = "#5d9d7d", -- Soft green
	bg = "none",
	italic = false,
})

-- Optional: Add subtle underline for better readability
vim.api.nvim_set_hl(0, "LspInlayHintUnderline", {
	fg = "none",
	bg = "none",
	underline = true,
	sp = "#3a3a3a", -- Underline color
})
-- Consistent ronding for boders
vim.diagnostic.config({
	float = { border = "rounded" },
})

vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#dba8ff" }) -- Purple for hints

-- Diagnostics
-- Your existing diagnostic configuration
-- vim.diagnostic.config({
-- 	virtual_lines = true,
-- 	severity_sort = true,
-- 	underline = { severity = vim.diagnostic.severity.ERROR },
-- 	signs = vim.g.have_nerd_font and {
-- 		text = {
-- 			[vim.diagnostic.severity.ERROR] = "󰅚 ",
-- 			[vim.diagnostic.severity.WARN] = "󰀪 ",
-- 			[vim.diagnostic.severity.INFO] = "󰋽 ",
-- 			[vim.diagnostic.severity.HINT] = "󰌶 ",
-- 		},
-- 	} or {},
-- })

-- -- Change the colors of the diagnostic signs
-- -- You can use standard color names or hex codes (e.g., "#ff0000")
-- vim.api.nvim_set_hl(0, "DiagnosticVirtualLinesInfo", { fg = "#ff6188" }) -- Red for errors
-- vim.api.nvim_set_hl(0, "DiagnosticVirtualLinesHint", { fg = "#ff6188" }) -- Red for errors
-- vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#ffd866" }) -- Yellow for warnings
-- vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#ff1200" }) -- Cyan for info
-- DiagnosticFloatingError xxx links to DiagnosticError
-- DiagnosticError xxx guifg=#c53b53
-- DiagnosticFloatingWarn xxx links to DiagnosticWarn
-- DiagnosticWarn xxx guifg=#ffc777
-- DiagnosticFloatingInfo xxx links to DiagnosticInfo
-- DiagnosticInfo xxx guifg=#0db9d7
-- DiagnosticFloatingHint xxx links to DiagnosticHint
-- DiagnosticHint xxx guifg=#4fd6be
-- DiagnosticFloatingOk xxx links to DiagnosticOk
-- DiagnosticOk   xxx ctermfg=10 guifg=NvimLightGreen
-- DiagnosticVirtualTextError xxx guifg=#c53b53
-- DiagnosticVirtualTextWarn xxx guifg=#ffc777
-- DiagnosticVirtualTextInfo xxx guifg=#0db9d7
-- DiagnosticVirtualTextHint xxx guifg=#4fd6be
-- DiagnosticVirtualTextOk xxx cleared
-- DiagnosticVirtualLinesError xxx links to DiagnosticError
-- DiagnosticVirtualLinesWarn xxx links to DiagnosticWarn
-- DiagnosticVirtualLinesInfo xxx links to DiagnosticInfo
-- DiagnosticVirtualLinesHint xxx links to DiagnosticHint
-- DiagnosticVirtualLinesOk xxx links to DiagnosticOk
-- DiagnosticSignError xxx links to DiagnosticError
-- DiagnosticSignWarn xxx links to DiagnosticWarn
-- DiagnosticSignInfo xxx links to DiagnosticInfo
-- DiagnosticSignHint xxx links to DiagnosticHint
-- DiagnosticSignOk xxx links to DiagnosticOk
-- DiagnosticUnnecessary xxx guifg=#444a73
