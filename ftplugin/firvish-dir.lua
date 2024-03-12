if vim.b.did_ftp == true then
    return
end

vim.opt_local.cursorline = true
vim.opt_local.cursorlineopt = "both"

require("firvish.config").internal.apply_mappings("dir")
