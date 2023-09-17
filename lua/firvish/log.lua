local vim = vim
local log = {}

function log.error(msg)
    vim.api.nvim_command([[echohl ErrorMsg]])
    vim.api.nvim_command("echo '[firvish] " .. msg .. "'")
    vim.api.nvim_command([[echohl Normal]])
end

function log.warning(msg)
    vim.api.nvim_command([[echohl WarningMsg]])
    vim.api.nvim_command("echo '[firvish] " .. msg .. "'")
    vim.api.nvim_command([[echohl Normal]])
end

return log
