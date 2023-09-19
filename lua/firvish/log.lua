local vim = vim
local log = {}

function log.error(msg)
    vim.notify("[firvish] " .. msg, vim.log.levels.ERROR, {})
end

function log.warning(msg)
    vim.notify("[firvish] " .. msg, vim.log.levels.WARN, {})
end

return log
