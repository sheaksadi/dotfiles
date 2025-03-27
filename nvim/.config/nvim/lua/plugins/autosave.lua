return {
  {
    "pocco81/auto-save.nvim",
    opts = {
      enabled = true, -- start auto-save when the plugin is loaded
      execution_message = {
        message = function() -- message to print on save
          return "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S")
        end,
        dim = 0.18, -- dim the color of `message`
        cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`
      },
      trigger_events = { "InsertLeave" }, -- vim events that trigger auto-save
      condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")
        local filetype = vim.bo.filetype
        local allowedFiles = { "javascript", "typescript", "python", "go", "vue", "rust", "java" }

        local isInList = false

        for _index, value in ipairs(allowedFiles) do
          if value == filetype then
            isInList = true
          end
        end

        if isInList then
          return true
        end
        return false
        -- if
        --   fn.getbufvar(buf, "&modifiable") == 1
        --   and utils.not_in(
        --     fn.getbufvar(buf, "&filetype"),
        --     { "javascript", "typescript", "python", "go", "vue", "rust", "java" }
        --   )
        -- then
        --   return false -- met condition(s), cuan save
        -- end
        -- return false -- can't save
      end,
      write_all_buffers = false, -- write all buffers when the current one meets `condition`
      debounce_delay = 5000, -- saves the file at most every `debounce_delay` milliseconds
      callbacks = { -- functions to be executed at different intervals
        enabling = nil, -- ran when enabling auto-save
        disabling = nil, -- ran when disabling auto-save
        before_asserting_save = nil, -- ran before checking `condition`
        before_saving = nil, -- ran before doing the actual save
        after_saving = nil, -- ran after doing the actual save
      },
    },
  },
}
