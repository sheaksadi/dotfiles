local map = vim.keymap.set

-- Increment/decrement numbers
map("n", "<leader>+", "<C-a>", { desc = "Increment number", silent = true })
map("n", "<leader>-", "<C-x>", { desc = "Decrement number", silent = true })

-- Move text up and down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected text down", silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected text up", silent = true })

-- Keep cursor centered while searching
map("n", "n", "nzzzv", { desc = "Next search result centered", silent = true })
map("n", "N", "Nzzzv", { desc = "Previous search result centered", silent = true })

-- Join lines without moving cursor
map("n", "J", "mzJ`z", { desc = "Join line without moving cursor", silent = true })

-- Paste without losing current register
map("x", "<leader>p", [["_dP]], { desc = "Paste without replacing register", silent = true })

-- Delete without copying to register
map("n", "<leader>d", [["_d]], { desc = "Delete without copying", silent = true })
map("v", "<leader>d", [["_d]], { desc = "Delete selection without copying", silent = true })

-- Quickfix list navigation
map("n", "<C-n>", ":cnext<CR>zz", { desc = "Next quickfix item", silent = true })
map("n", "<C-p>", ":cprev<CR>zz", { desc = "Previous quickfix item", silent = true })

-- Tab navigation
map("n", "<leader>to", ":tabnew<CR>", { desc = "Open new tab", silent = true })
map("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab", silent = true })
map("n", "<leader>tn", ":tabn<CR>", { desc = "Next tab", silent = true })
map("n", "<leader>tp", ":tabp<CR>", { desc = "Previous tab", silent = true })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center", silent = true })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center", silent = true })

-- Keep cursor centered when jumping through the jumplist
map("n", "<C-o>", "<C-o>zz", { desc = "Jump back and center", silent = true })
map("n", "<C-i>", "<C-i>zz", { desc = "Jump forward and center", silent = true })

-- Increase split size
map("n", "<A-Left>", ":vertical resize -5<CR>", { desc = "Decrease width", silent = true })
map("n", "<A-Right>", ":vertical resize +5<CR>", { desc = "Increase width", silent = true })
map("n", "<A-Up>", ":resize +5<CR>", { desc = "Increase height", silent = true })
map("n", "<A-Down>", ":resize -5<CR>", { desc = "Decrease height", silent = true })
