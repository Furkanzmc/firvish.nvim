if vim.b.did_ftp == true then
    return
end

local opt_local = vim.opt_local

opt_local.cursorline = true

require("firvish.config").apply_mappings("job")
