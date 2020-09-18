local vim = vim
local M = {}
local utils = require'firvish.utils'

local open_bufnr = nil
local cached_buffers = nil

function create_buffer_list()
  local buffer_information = vim.fn.getbufinfo()
  local buffers = {}
  local option = {}
  local all_buffers = vim.fn.range(1, vim.fn.bufnr('$'))
  local buf_num_length = #tostring(#all_buffers)

  for key,bufnr in ipairs(all_buffers) 
  do
    if vim.fn.buflisted(bufnr) == 1 and bufnr ~= open_bufnr then
      local bufnr_str = "[" .. bufnr .. "]"
      local line = bufnr_str
      local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
      local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
      local bufname = vim.fn.bufname(bufnr)
      bufname = vim.fn.fnamemodify(bufname, ":p:~:.")

      if modified then
        line = line .. " +"
      end

      line = line .. string.rep(" ", buf_num_length - (#bufnr_str - 2) + 1)
      if bufname == "" then
        line = line .. "[No Name]"
      else
        line = line ..  bufname
      end

      if filetype ~= "qf" then
        buffers[#buffers + 1] = line
        option[#option + 1] = {bufnr=bufnr, name=bufname}
      end
    end
  end

  return {buffers, option}

end

function is_window_visible(tabnr, bufnr)
  local buffers = vim.fn.tabpagebuflist(tabnr)
  for _,win in pairs(buffers)
  do
    if win == bufnr then
      return true
    end
  end

  return false
end

M.jump_to_buffer = function()
  local linenr = vim.fn.line(".")
  local bufnr = open_bufnr
  local buffer_info = vim.api.nvim_buf_get_var(bufnr, "firvish").buffers[linenr]

  M.firvish_close()

  local jump_info = utils.find_open_window(buffer_info.bufnr)
  if jump_info.tabnr ~= -1 and jump_info.winnr ~= -1 then
    utils.jump_to_window(jump_info.tabnr, jump_info.winnr)
  else
    vim.api.nvim_command("buffer " .. buffer_info.bufnr)
  end
end

M.on_buf_delete = function()
  open_bufnr = nil
end

M.on_buf_leave = function()
  previous_bufnr = nil
end

M.firvish_close = function()
  if previous_bufnr ~= nil then
    vim.api.nvim_command("buffer " .. previous_bufnr)
  end

  previous_bufnr = nil
end

M.open_buffer_list = function()
  local tabnr = vim.fn.tabpagenr()
  previous_bufnr = vim.fn.bufnr()

  if open_bufnr == nil then
    open_bufnr = utils.show_preview("neovim-firvish [buffers]", "firvish")
    vim.api.nvim_command("augroup neovim_firvish_buffer")
    vim.api.nvim_command("autocmd! * <buffer>")
    vim.api.nvim_command("autocmd BufDelete <buffer> lua require'firvish'.on_buf_delete()")
    vim.api.nvim_command("autocmd BufWipeout <buffer> lua require'firvish'.on_buf_delete()")
    vim.api.nvim_command("autocmd BufLeave <buffer> lua require'firvish'.on_buf_leave()")
    vim.api.nvim_command("augroup END")
  elseif is_window_visible(tabnr, open_bufnr) then
    vim.api.nvim_command(vim.fn.bufwinnr(open_bufnr) .. "wincmd w")
  end

  vim.api.nvim_command("buffer " .. open_bufnr)

  local info = create_buffer_list()
  utils.set_lines(open_bufnr, info[1])

  vim.api.nvim_buf_set_var(open_bufnr, "firvish", {buffers=info[2]})
end

M.refresh_buffer_list = function()
  local info = create_buffer_list()
  utils.set_lines(open_bufnr, info[1])

  vim.api.nvim_buf_set_var(open_bufnr, "firvish", {buffers=info[2]})
end

return M
