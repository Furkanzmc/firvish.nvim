local vim = vim
local cmd = vim.cmd
local log = {}

function log.error(msg)
  cmd [[echohl ErrorMsg]]
  cmd("echo '[firvish] " .. msg .. "'")
  cmd [[echohl Normal]]
end

function log.warning(msg)
  cmd [[echohl WarningMsg]]
  cmd("echo '[firvish] " .. msg .. "'")
  cmd [[echohl Normal]]
end

return log
