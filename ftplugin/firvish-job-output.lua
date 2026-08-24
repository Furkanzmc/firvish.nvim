if vim.b.did_ftp == true then
    return
end
vim.b.did_ftp = true

local bufnr = vim.api.nvim_get_current_buf()

vim.api.nvim_set_option_value("cursorline", true, { win = 0 })
vim.api.nvim_set_option_value("cursorlineopt", "both", { win = 0 })

require("firvish.config").internal.apply_mappings("job-output")

local group = vim.api.nvim_create_augroup("firvish_job_output_preview", { clear = true })
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "WinClosed" }, {
    group = group,
    buffer = bufnr,
    callback = function()
        require("firvish.job_control").on_job_output_preview_bufdeleter()
    end,
})
