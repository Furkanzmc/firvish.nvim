if vim.b.did_firvish_dir == true then return end

vim.opt_local.cursorline = true

require'firvish'.configure_buffer_preview_keymaps()

vim.b.did_firvish_dir = true
