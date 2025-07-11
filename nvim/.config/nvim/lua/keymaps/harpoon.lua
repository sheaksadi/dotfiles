local harpoon = require("harpoon")
local telescope = require("telescope")

-- Quick mark current file
vim.keymap.set("n", "<leader>a", function()
	harpoon:list():append()
end, { desc = "Harpoon: Add file" })

-- -- Open Harpoon marks in Telescope (fuzzy search!)
-- vim.keymap.set("n", "<leader>hm", function()
-- 	telescope.extensions.harpoon.marks(require("telescope.themes").get_dropdown({}))
-- end, { desc = "Harpoon: Telescope Marks" })

-- Quick jump to marks (no mouse needed)
for i = 1, 4 do
	vim.keymap.set("n", "<leader>" .. i, function()
		harpoon:list():select(i)
	end, { desc = "Harpoon: Jump to mark " .. i })
end

-- Cycle through marks (optional)
vim.keymap.set("n", "<C-p>", function()
	harpoon:list():prev()
end, { desc = "Harpoon: Prev mark" })
vim.keymap.set("n", "<C-n>", function()
	harpoon:list():next()
end, { desc = "Harpoon: Next mark" })

vim.keymap.set("n", "<C-h>", function()
	harpoon:list():select(1)
end, { desc = "Harpoon: Jump to mark 1" })
vim.keymap.set("n", "<C-j>", function()
	harpoon:list():select(2)
end, { desc = "Harpoon: Jump to mark 2" })
vim.keymap.set("n", "<C-k>", function()
	harpoon:list():select(3)
end, { desc = "Harpoon: Jump to mark 3" })
vim.keymap.set("n", "<C-l>", function()
	harpoon:list():select(4)
end, { desc = "Harpoon: Jump to mark 4" })

-- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
	local file_paths = {}
	for _, item in ipairs(harpoon_files.items) do
		table.insert(file_paths, item.value)
	end

	require("telescope.pickers")
		.new({}, {
			prompt_title = "Harpoon",
			finder = require("telescope.finders").new_table({
				results = file_paths,
			}),
			previewer = conf.file_previewer({}),
			sorter = conf.generic_sorter({}),
		})
		:find()
end

vim.keymap.set("n", "<C-e>", function()
	toggle_telescope(harpoon:list())
end, { desc = "Open harpoon window" })

-- Remove current buffer from Harpoon list
vim.keymap.set("n", "<leader>hx", function()
	harpoon:list():remove()
end, { desc = "Harpoon: Remove current buffer" })
