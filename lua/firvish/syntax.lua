local vim = vim
local M = {}

M.set_common_syntax = function()
    vim.cmd([[
        syntax match FirvishError "^ERROR:"
        syntax match FirvishWarning "^WARNING:"
        syntax match FirvishInfo "^INFO:"

        highlight default link FirvishError ErrorMsg
        highlight default link FirvishWarning WarningMsg
        highlight default link FirvishInfo IncSearch
    ]])
end

return M
