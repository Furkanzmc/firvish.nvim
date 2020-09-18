local vim = vim
local M = {}
local utils = require'firvish.utils'
local buffers = require'firvish.buffers'

M.open_buffer_list = function()
  buffers.open_buffer_list()
end

M.refresh_buffer_list = function()
  buffers.refresh_buffer_list()
end

return M
