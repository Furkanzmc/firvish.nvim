if vim.b.did_ftp == true then
    return
end

vim.opt_local.cursorline = true

require("firvish.config").internal.apply_mappings("dir")
