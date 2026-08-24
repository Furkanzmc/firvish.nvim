if vim.b.did_ftp == true then
    return
end
vim.b.did_ftp = true

local bufnr = vim.api.nvim_get_current_buf()

vim.api.nvim_set_option_value("cursorline", true, { win = 0 })
vim.api.nvim_set_option_value("cursorlineopt", "both", { win = 0 })
vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
vim.api.nvim_set_option_value("buflisted", true, { buf = bufnr })
vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })

vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_set_option_value("syntax", "firvish-buffers", { buf = bufnr })
    end
end)

require("firvish.config").internal.apply_mappings("buffers")

vim.api.nvim_buf_create_user_command(bufnr, "Bufdo", function(args)
    require("firvish.buffers").buf_do(args.line1, args.line2, args.args)
end, { nargs = "*", range = true, desc = "Firvish Bufdo" })

vim.api.nvim_buf_create_user_command(bufnr, "Bdelete", function(args)
    require("firvish.buffers").buf_delete(args.line1, args.line2, args.bang)
end, { nargs = "*", range = true, bang = true, desc = "Firvish Bdelete" })

local group = vim.api.nvim_create_augroup("firvish_buffers_local", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    buffer = bufnr,
    callback = function()
        require("firvish.buffers").on_buf_enter()
    end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    buffer = bufnr,
    callback = function()
        require("firvish.buffers").on_buf_delete()
    end,
})

vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    buffer = bufnr,
    callback = function()
        require("firvish.buffers").on_buf_leave()
    end,
})
