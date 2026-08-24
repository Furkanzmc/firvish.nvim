if vim.b.did_ftp == true then
    return
end
vim.b.did_ftp = true

vim.api.nvim_set_option_value("cursorline", true, { win = 0 })
vim.api.nvim_set_option_value("cursorlineopt", "both", { win = 0 })

require("firvish.config").internal.apply_mappings("dir")
