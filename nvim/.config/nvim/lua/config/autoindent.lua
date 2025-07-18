vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    group = vim.api.nvim_create_augroup("auto_indent_on_insert_final", { clear = true }),
    callback = function()
        vim.schedule(function()
            local lnum = vim.api.nvim_win_get_cursor(0)[1]
            local current_line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]

            if lnum > 1 and current_line and current_line:match("^%s*$") then
                local prev_lnum = lnum - 1
                local prev_line_content = ""
                while prev_lnum > 0 do
                    prev_line_content = vim.api.nvim_buf_get_lines(0, prev_lnum - 1, prev_lnum, false)[1]
                    if prev_line_content and not prev_line_content:match("^%s*$") then
                        break
                    end
                    prev_lnum = prev_lnum - 1
                end

                if prev_lnum > 0 then
                    local indent_str = prev_line_content:match("^%s*")
                    if indent_str and #indent_str > 0 then
                        vim.api.nvim_feedkeys(indent_str, 'n', false)
                    end
                end
            end
        end)
    end,
})
