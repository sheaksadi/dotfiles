function indent_with_i()
  if vim.fn.getline('.') == '' then
    return '"_cc'
  else
    return 'i'
  end
end

function indent_with_a()
  if vim.fn.getline('.') == '' then
    return '"_cc'
  else
    return 'a'
  end
end

vim.api.nvim_set_keymap('n', 'i', 'v:lua.indent_with_i()', { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'a', 'v:lua.indent_with_a()', { expr = true, noremap = true, silent = true })
