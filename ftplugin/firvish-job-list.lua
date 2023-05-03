if vim.b.did_ftp == true then
    return
end

local cmd = vim.cmd
local opt_local = vim.opt_local

opt_local.modifiable = false
opt_local.readonly = true
opt_local.cursorline = true

require("firvish.config").apply_mappings("job-list")

cmd([[augroup firvish_job_list_preview]])
cmd([[autocmd! * <buffer>]])
cmd([[autocmd BufDelete,BufWipeout,WinClosed <buffer> lua require'firvish.job_control'.on_job_list_bufdelete()]])
cmd([[augroup END]])
