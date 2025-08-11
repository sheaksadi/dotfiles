-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Close empty buffers automatically
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if vim.bo.buftype == "" and vim.fn.expand("%") == "" and vim.fn.line2byte("$") == -1 then
			vim.cmd("bd")
		end
	end,
})

-- Create a command group to prevent this autocmd from being duplicated
-- if you ever reload your configuration. This is standard best practice.
local cr_fix_group = vim.api.nvim_create_augroup("FixCR", { clear = true })

-- Create the autocmd that will run on every file you save.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = cr_fix_group,
	pattern = "*", -- The pattern "*" means "any file".

	-- The command to run on the current buffer. This is NOT a loop.
	-- It's a single search-and-replace operation.
	command = [[%s/\r$//e]],
})
-- Create a command group to prevent this autocmd from being duplicated
-- if you ever reload your configuration. This is standard best practice.
local cr_fix_group = vim.api.nvim_create_augroup("FixCR", { clear = true })

-- Create the autocmd that will run on every file you save.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = cr_fix_group,
	pattern = "*", -- The pattern "*" means "any file".

	-- The command to run on the current buffer. This is NOT a loop.
	-- It's a single search-and-replace operation.
	command = [[%s/\r$//e]],
})

-- LSP ATTACH
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		-- Find references for the word under your cursor.
		map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

		-- Jump to the implementation of the word under your cursor.
		--  Useful when your language has ways of declaring types without an actual implementation.
		map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

		-- Jump to the definition of the word under your cursor.
		--  This is where a variable was first declared, or where a function is defined, etc.
		--  To jump back, press <C-t>.
		map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

		-- WARN: This is not Goto Definition, this is Goto Declaration.
		--  For example, in C this would take you to the header.
		map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		-- Fuzzy find all the symbols in your current document.
		--  Symbols are things like variables, functions, types, etc.
		map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

		-- Fuzzy find all the symbols in your current workspace.
		--  Similar to document symbols, except searches over your entire project.
		map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

		-- Jump to the type of the word under your cursor.
		--  Useful when you're not sure what type a variable is and you want to see
		--  the definition of its *type*, not where it was *defined*.
		map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

		-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
		---@param client vim.lsp.Client
		---@param method vim.lsp.protocol.Method
		---@param bufnr? integer some lsp support methods only in specific files
		---@return boolean
		local function client_supports_method(client, method, bufnr)
			return client:supports_method(method, bufnr)
		end

		-- Helper function to brighten a hex color
		local function brighten_hex_color(hex_color, amount)
			if not hex_color or hex_color == "" then
				return nil
			end
			local r = tonumber(hex_color:sub(2, 3), 16)
			local g = tonumber(hex_color:sub(4, 5), 16)
			local b = tonumber(hex_color:sub(6, 7), 16)
			r = math.min(255, math.floor(r * (1 + amount)))
			g = math.min(255, math.floor(g * (1 + amount)))
			b = math.min(255, math.floor(b * (1 + amount)))
			return string.format("#%02x%02x%02x", r, g, b)
		end

		local function get_hl(name)
			local get_hl_opts = { name = name, link = false, create = false }

			local ok, hl = pcall(vim.api.nvim_get_hl, 0, get_hl_opts)

			if not ok or not hl then
				return nil
			end

			for _, key in pairs({ "fg", "bg", "sp" }) do
				if hl[key] and type(hl[key]) == "number" then
					hl[key] = string.format("#%06x", hl[key])
				end
			end

			return hl
		end

		local showBlindingRed = false
		-- This function will be called to set the highlight
		local function set_lsp_reference_highlight()
			if showBlindingRed then
				vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#ff0000", fg = "#ffffff" }) -- Red background, white text
				vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#ff0000", fg = "#ffffff" })
				vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#ff0000", fg = "#ffffff" })
				return
			end

			local result = vim.treesitter.get_captures_at_cursor(0)
			result = result[#result]

			if not result then
				return
			end
			local group = get_hl("@" .. result)

			for key, value in pairs(group) do
				if type(value) ~= "string" then
					print(value)
					return
				end

				local fg_color_hex = value

				if not fg_color_hex then
					return
				end

				local brighter_hex = brighten_hex_color(fg_color_hex, 0.5) -- Adjust brightness

				if not brighter_hex then
					return
				end

				-- Set the LspReference highlights to be brightened with no background
				vim.api.nvim_set_hl(0, "LspReferenceText", { fg = brighter_hex, bg = "NONE", bold = true })
				vim.api.nvim_set_hl(0, "LspReferenceRead", { fg = brighter_hex, bg = "NONE", bold = true })
				vim.api.nvim_set_hl(0, "LspReferenceWrite", { fg = brighter_hex, bg = "NONE", bold = true })
			end
		end

		-- The following two autocommands are used to highlight references of the
		-- word under your cursor when your cursor rests there for a little while.
		--    See `:help CursorHold` for information about when this is executed
		--
		-- When you move your cursor, the highlights will be cleared (the second autocommand).
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if
			client
			and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
		then
			local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHoldI", "CursorHold" }, {
				-- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = function()
					set_lsp_reference_highlight() -- Set our dynamic highlight first
					vim.lsp.buf.document_highlight() -- Then trigger the LSP action
				end,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
				end,
			})
		end
		vim.keymap.set(
			"n",
			"<leader>lr",
			function()
				showBlindingRed = not showBlindingRed
			end, -- The action to trigger
			{ buffer = event.buf, desc = "[L]SP: [R]ed" }
		)
		vim.keymap.set(
			{ "n", "v" }, -- Normal and Visual modes
			"<leader>ca", -- Your quick action key
			vim.lsp.buf.code_action, -- The action to trigger
			{ buffer = event.buf, desc = "LSP: Quick actions" }
		)
		-- The following code creates a keymap to toggle inlay hints in your
		-- code, if the language server you are using supports them
		--
		-- This may be unwanted, since they displace some of your code
		if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
			map("<leader>th", function()
				-- vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#7aa2f7", italic = true })

				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[T]oggle Inlay [H]ints")
		end
	end,
})
