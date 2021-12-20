local vim = vim
local M = {}
local utils = require "firvish.utils"

local s_open_bufnr = -1
local s_buffer_list_dirty = true
local s_cached_buffers = {}

local function create_buffer_list(predicate)
  if s_buffer_list_dirty == false then
    return s_cached_buffers
  end

  local buffer_information = vim.fn.getbufinfo()
  local buffers = {}
  local all_buffers = vim.fn.range(1, vim.fn.bufnr "$")
  local buf_num_length = #tostring(#all_buffers)

  for key, bufnr in ipairs(all_buffers) do
    if
      vim.fn.buflisted(bufnr) == 1
      and bufnr ~= s_open_bufnr
      and (predicate == nil or (predicate ~= nil and predicate(bufnr) == true))
    then
      local bufnr_str = "[" .. bufnr .. "]"
      local line = bufnr_str
      local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
      local bufname = vim.fn.bufname(bufnr)
      bufname = vim.fn.fnamemodify(bufname, ":p:~:.")

      if modified then
        line = line .. " +"
      end

      line = line .. string.rep(" ", buf_num_length - (#bufnr_str - 2) + 1)
      if bufname == "" then
        line = line .. "[No Name]"
      else
        line = line .. bufname
      end

      buffers[#buffers + 1] = line
    end
  end

  s_cached_buffers = buffers
  s_buffer_list_dirty = false
  return s_cached_buffers
end

local function get_bufnr(linenr)
  local line = vim.fn.getbufline(s_open_bufnr, linenr)[1]
  local bufnr = vim.fn.substitute(vim.fn.matchstr(line, "[[0-9]\\+]"), "\\(\\[\\|\\]\\)", "", "g")

  if bufnr ~= "" then
    return tonumber(bufnr)
  end

  local buffer_name = string.sub(line, vim.fn.matchstrpos(line, "[A-Za-z]")[2], -1)
  local buffer_name = vim.fn.trim(buffer_name)
  bufnr = vim.fn.bufnr(buffer_name)

  if bufnr == -1 then
    utils.log_error "Cannot read buffer number from the list."
    return -1
  end

  return tonumber(bufnr)
end

M.on_buf_delete = function()
  s_open_bufnr = -1
end

M.on_buf_enter = function()
  M.open_buffers()
end

M.on_buf_leave = function() end

M.mark_dirty = function()
  s_buffer_list_dirty = true
end

M.jump_to_buffer = function()
  local bufnr = get_bufnr(vim.fn.line ".")
  if bufnr == -1 then
    return
  end

  local jump_info = utils.find_open_window(bufnr)
  if jump_info.tabnr ~= -1 and jump_info.winnr ~= -1 then
    utils.jump_to_window(jump_info.tabnr, jump_info.winnr)
  else
    vim.api.nvim_command("buffer " .. bufnr)
  end
end

M.open_buffers = function()
  local tabnr = vim.fn.tabpagenr()

  if vim.fn.bufexists(s_open_bufnr) == 0 then
    vim.api.nvim_command "e firvish://buffers"
    s_open_bufnr = vim.fn.bufnr()

    M.refresh_buffers()
  elseif utils.is_window_visible(tabnr, s_open_bufnr) then
    vim.api.nvim_command(vim.fn.bufwinnr(s_open_bufnr) .. "wincmd w")
    M.refresh_buffers()
  else
    vim.api.nvim_command("buffer " .. s_open_bufnr)
    M.refresh_buffers()
  end
end

M.refresh_buffers = function()
  assert(s_open_bufnr ~= -1, "s_open_bufnr must be valid.")
  s_buffer_list_dirty = true
  local lines = create_buffer_list()
  local cursor = vim.api.nvim_win_get_cursor(0)
  utils.set_buf_lines(s_open_bufnr, lines)

  if cursor[1] > #lines then
    cursor[1] = #lines - 1
  end

  if cursor[1] > 0 then
    vim.api.nvim_win_set_cursor(0, cursor)
  end
end

M.filter_buffers = function(mode)
  local buffers = nil
  s_buffer_list_dirty = true
  if mode == "modified" then
    buffers = create_buffer_list(function(bufnr)
      return vim.api.nvim_buf_get_option(bufnr, "modified")
    end)
  elseif mode == "current_tab" then
    local tabnr = vim.fn.tabpagenr()
    buffers = create_buffer_list(function(bufnr)
      return utils.is_window_visible(tabnr, bufnr)
    end)
  elseif mode == "args" then
    local args = vim.fn.argv()
    local args_bufnr = {}
    for index, arg in ipairs(args) do
      args_bufnr[index] = vim.fn.bufnr(arg)
    end

    buffers = create_buffer_list(function(bufnr)
      return utils.any_of(args_bufnr, function(v)
        return v == bufnr
      end)
    end)
  else
    assert(false, "Unsupported filter type: " .. mode)
  end

  utils.set_buf_lines(s_open_bufnr, buffers)
end

M.buf_do = function(start_line, end_line, cmd)
  for linenr = start_line, end_line, 1 do
    vim.api.nvim_command("buffer " .. get_bufnr(linenr))
    vim.api.nvim_command(cmd)
  end

  vim.api.nvim_command("buffer " .. s_open_bufnr)
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

M.buf_count = function()
  local buffers = create_buffer_list()
  return #buffers
end

return M
