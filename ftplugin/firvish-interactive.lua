if vim.b.did_ftp == true then
    return
end
vim.b.did_ftp = true

local bufnr = vim.api.nvim_get_current_buf()

vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
vim.api.nvim_set_option_value("cursorline", true, { win = 0 })
vim.api.nvim_set_option_value("cursorlineopt", "both", { win = 0 })
vim.api.nvim_set_option_value("buflisted", false, { buf = bufnr })
vim.api.nvim_set_option_value("buftype", "nowrite", { buf = bufnr })
