if vim.b.did_firvish_dir == true then return end

vim.opt_loca.cursorline = true

require'firvish'.configure_buffer_preview_keymaps()

vim.b.did_firvish_dir = true
