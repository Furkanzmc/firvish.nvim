if vim.b.did_ftp == true then
    return
end
vim.b.did_ftp = true

local bufnr = vim.api.nvim_get_current_buf()

vim.api.nvim_set_option_value("cursorline", true, { win = 0 })
vim.api.nvim_set_option_value("cursorlineopt", "both", { win = 0 })
vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
vim.api.nvim_set_option_value("buflisted", true, { buf = bufnr })
vim.api.nvim_set_option_value("syntax", "firvish-buffers", { buf = bufnr })
vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })

require("firvish.config").internal.apply_mappings("history")

local group = vim.api.nvim_create_augroup("firvish_history_local", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    buffer = bufnr,
    callback = function()
        require("firvish.history").open_history()
    end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    buffer = bufnr,
    callback = function()
        require("firvish.history").on_buf_delete()
    end,
})

vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    buffer = bufnr,
    callback = function()
        require("firvish.history").on_buf_leave()
    end,
})
