vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufAdd" }, {
    group = vim.api.nvim_create_augroup("firvish_ft", { clear = true }),
    pattern = { "firvish://buffers", "firvish://history" },
    callback = function(ev)
        if ev.match == "firvish://buffers" then
            vim.opt_local.filetype = "firvish-buffers"
        elseif ev.match == "firvish://history" then
            vim.opt_local.filetype = "firvish-history"
        end
    end,
})
