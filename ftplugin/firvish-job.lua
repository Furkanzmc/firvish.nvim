if vim.b.did_ftp == true then return end

local map = require"firvish.utils".map
local opt_local = vim.opt_local
local firvish = require 'firvish'

opt_local.cursorline = true

firvish.configure_buffer_preview_keymaps()
