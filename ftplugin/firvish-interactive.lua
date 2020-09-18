if vim.b.did_firvish_interactive == true then return end

local opt_local = vim.opt_local

opt_local.modifiable = true
opt_local.cursorline = true
opt_local.buflisted = false

opt_local.buftype = "nowrite"

vim.b.did_firvish_interactive = true
