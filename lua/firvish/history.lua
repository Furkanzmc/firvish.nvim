local vim = vim
local M = {}
local utils = require'firvish.utils'

local open_bufnr = nil

function get_history(predicate)
  local old_files = vim.api.nvim_get_vvar("oldfiles")
  local history = {}
  for index,file in ipairs(old_files)
  do
    if vim.fn.filereadable(file) == 1 and (predicate == nil or (predicate ~= nil and predicate(file) == true)) then
      history[#history + 1] = vim.fn.fnamemodify(file, ":p:~:.")
    end
  end

  return history
end

M.on_buf_delete = function()
  open_bufnr = nil
end

M.on_buf_leave = function()
  previous_bufnr = nil
end

M.close_history = function()
  if previous_bufnr ~= nil then
    vim.api.nvim_command("buffer " .. previous_bufnr)
  else
    vim.api.nvim_command("bdelete! " .. open_bufnr)
    open_bufnr = nil
  end

  previous_bufnr = nil
end

M.open_history = function()
  local tabnr = vim.fn.tabpagenr()
  previous_bufnr = vim.fn.bufnr()

  if open_bufnr == nil then
    open_bufnr = utils.show_preview("firvish [history]", "firvish-history", nil)
    vim.api.nvim_command("augroup neovim_firvish_history")
    vim.api.nvim_command("autocmd! * <buffer>")
    vim.api.nvim_command("autocmd BufDelete <buffer> lua require'firvish.history'.on_buf_delete()")
    vim.api.nvim_command("autocmd BufWipeout <buffer> lua require'firvish.history'.on_buf_delete()")
    vim.api.nvim_command("autocmd BufLeave <buffer> lua require'firvish.history'.on_buf_leave()")
    vim.api.nvim_command("augroup END")
  elseif utils.is_window_visible(tabnr, open_bufnr) then
    vim.api.nvim_command(vim.fn.bufwinnr(open_bufnr) .. "wincmd w")
  end

  vim.api.nvim_command("buffer " .. open_bufnr)

  local history = get_history(nil)
  utils.set_lines(open_bufnr, history)
end

M.refresh_history = function()
  M.open_history()
end

M.open_file = function()
  local linenr = vim.fn.line(".")
  local lines = vim.api.nvim_buf_get_lines(open_bufnr, linenr - 1, linenr, true)
  vim.api.nvim_command("edit " .. lines[1])
end

return M
