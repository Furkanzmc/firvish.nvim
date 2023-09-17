if vim.b.did_ftp == true then
    return
end

local opt_local = vim.opt_local

opt_local.cursorline = true
opt_local.modifiable = true
opt_local.buflisted = true
opt_local.syntax = "firvish-buffers"
opt_local.buftype = "nofile"
opt_local.swapfile = false

require("firvish.config").internal.apply_mappings("buffers")

vim.api.nvim_create_user_command("Bufdo", function(args)
    require("firvish.buffers").buf_do(args.line1, args.line2, args.args)
end, { nargs = "*", range = true })

vim.api.nvim_create_user_command("Bdelete", function(args)
    require("firvish.buffers").buf_delete(args.line1, args.line2, args.bang)
end, { nargs = "*", range = true, bang = true })

local autocmd_group = vim.api.nvim_create_augroup("neovim_firvish_buffer_local", { clear = true })
local bufnr = vim.fn.bufnr()
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = autocmd_group,
    callback = function(_)
        require("firvish.buffers").on_buf_enter()
    end,
    buffer = bufnr,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = autocmd_group,
    callback = function(_)
        require("firvish.buffers").on_buf_delete()
    end,
    buffer = bufnr,
})

vim.api.nvim_create_autocmd({ "BufLeave" }, {
    group = autocmd_group,
    callback = function(_)
        require("firvish.buffers").on_buf_leave()
    end,
    buffer = bufnr,
})
