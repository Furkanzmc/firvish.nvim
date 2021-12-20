if vim.b.did_ftp == true then
    return
end

vim.opt_local.cursorline = true

require("firvish.config").apply_mappings "dir"
