if vim.b.did_ftp == true then
    return
end

local opt_local = vim.opt_local

opt_local.cursorline = true
opt_local.cursorlineopt = "both"

require("firvish.config").internal.apply_mappings("job")
