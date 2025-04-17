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

