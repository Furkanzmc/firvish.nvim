if vim.b.did_ftp == true then
    return
end

local cmd = vim.cmd
local opt_local = vim.opt_local

opt_local.cursorline = true
opt_local.cursorlineopt = "both"

require("firvish.config").internal.apply_mappings("job-output")

cmd([[augroup firvish_job_output_preview]])
cmd([[autocmd! * <buffer>]])
cmd([[autocmd BufDelete,BufWipeout,WinClosed <buffer> lua require'firvish.job_control'.on_job_output_preview_bufdeleter()]])
cmd([[augroup END]])
