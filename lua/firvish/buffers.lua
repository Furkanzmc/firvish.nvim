local vim = vim
local M = {}
local utils = require'firvish.utils'

local open_bufnr = nil
local cached_buffers = nil
local is_buffers_dirty = false

function create_buffer_list(predicate)
  local buffer_information = vim.fn.getbufinfo()
  local buffers = {}
  local all_buffers = vim.fn.range(1, vim.fn.bufnr('$'))
  local buf_num_length = #tostring(#all_buffers)

  for key,bufnr in ipairs(all_buffers) 
  do
    if vim.fn.buflisted(bufnr) == 1 and bufnr ~= open_bufnr 
      and (predicate == nil or (predicate ~= nil and predicate(bufnr) == true)) then
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
      end
    end
  end

  is_buffers_dirty = false
  return buffers

end

M.on_buf_delete = function()
  open_bufnr = nil
end

M.on_buf_enter = function()
  if is_buffers_dirty == true then
    M.refresh_buffers()
  end
end

M.on_buf_leave = function()
  previous_bufnr = nil
end

M.close_buffers = function()
  if previous_bufnr ~= nil then
    vim.api.nvim_command("buffer " .. previous_bufnr)
  end

  previous_bufnr = nil
end

M.mark_dirty = function()
  is_buffers_dirty = true
end

function get_bufnr(linenr)
  local buffer_name = vim.fn.trim(string.gsub(vim.fn.getline(linenr), "[[0-9]+]", ""))
  local bufnr = vim.fn.bufnr(buffer_name)

  if bufnr == -1 then
    utils.log_error("Cannot read buffer number from the list.")
    return nil
  end

  return bufnr
end

M.jump_to_buffer = function()
  local bufnr = get_bufnr(vim.fn.line("."))

  M.close_buffers()

  local jump_info = utils.find_open_window(bufnr)
  if jump_info.tabnr ~= -1 and jump_info.winnr ~= -1 then
    utils.jump_to_window(jump_info.tabnr, jump_info.winnr)
  else
    vim.api.nvim_command("buffer " .. bufnr)
  end
end

M.open_buffers = function()
  local tabnr = vim.fn.tabpagenr()
  previous_bufnr = vim.fn.bufnr()

  if open_bufnr == nil then
    open_bufnr = utils.show_preview("firvish [buffers]", "firvish-buffers", nil)
    vim.api.nvim_command("augroup neovim_firvish_buffer_local")
    vim.api.nvim_command("autocmd! * <buffer>")
    vim.api.nvim_command("autocmd BufEnter <buffer> lua require'firvish.buffers'.on_buf_enter()")
    vim.api.nvim_command("autocmd BufDelete <buffer> lua require'firvish.buffers'.on_buf_delete()")
    vim.api.nvim_command("autocmd BufWipeout <buffer> lua require'firvish.buffers'.on_buf_delete()")
    vim.api.nvim_command("autocmd BufLeave <buffer> lua require'firvish.buffers'.on_buf_leave()")
    vim.api.nvim_command("augroup END")
  elseif utils.is_window_visible(tabnr, open_bufnr) then
    vim.api.nvim_command(vim.fn.bufwinnr(open_bufnr) .. "wincmd w")
  end

  vim.api.nvim_command("buffer " .. open_bufnr)

  local buffers = create_buffer_list()
  utils.set_lines(open_bufnr, buffers)
end

M.refresh_buffers = function()
  local lines = create_buffer_list()
  local cursor = vim.api.nvim_win_get_cursor(0)
  utils.set_lines(open_bufnr, lines)
  if cursor[1] > #lines then
    cursor[1] = #lines - 1
  end

  vim.api.nvim_win_set_cursor(0, cursor)
end

M.filter_buffers = function(mode)
  local buffers = nil
  if mode == "modified" then
    buffers = create_buffer_list(function(bufnr)
      return vim.api.nvim_buf_get_option(bufnr, "modified")
    end)
  elseif mode == "current_tab" then
    local tabnr = vim.fn.tabpagenr()
    buffers = create_buffer_list(function(bufnr)
      return utils.is_window_visible(tabnr, bufnr)
    end)
  else
    assert(false, "Unsupported filter type: " .. mode)
  end

  utils.set_lines(open_bufnr, buffers)
end

M.buf_do = function(start_line, end_line, cmd)
  local firvish = vim.api.nvim_buf_get_var(open_bufnr, "firvish_buffers")
  local start_buffer = firvish.buffers[start_line]
  local end_buffer = firvish.buffers[end_line]

  vim.api.nvim_command(start_buffer.bufnr .. "," .. end_buffer.bufnr .. "bufdo " .. cmd)
  vim.api.nvim_command("buffer " .. open_bufnr)
end

M.buf_delete = function(start_line, end_line, force)
  local start_buffer = get_bufnr(start_line)
  local end_buffer = get_bufnr(end_line)

  if not force then
    vim.api.nvim_command(start_buffer .. "," .. end_buffer .. "bdelete")
  else
    vim.api.nvim_command(start_buffer .. "," .. end_buffer .. "bdelete!")
  end

  M.refresh_buffers()
end

return M
