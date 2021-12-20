local vim = vim
local M = {}

M.set_common_syntax = function()
  vim.api.nvim_command 'syntax match FirvishError "^ERROR:"'
  vim.api.nvim_command 'syntax match FirvishWarning "^WARNING:"'
  vim.api.nvim_command 'syntax match FirvishInfo "^INFO:"'

  vim.api.nvim_command "highlight default link FirvishError ErrorMsg"
  vim.api.nvim_command "highlight default link FirvishWarning WarningMsg"
  vim.api.nvim_command "highlight default link FirvishInfo IncSearch"
end

return M
