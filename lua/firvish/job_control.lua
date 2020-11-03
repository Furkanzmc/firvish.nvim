local vim = vim
local M = {}
local utils = require'firvish.utils'

local jobs = {}
local job_count = 1
local opened_buffers = {}


function on_stdout(job_id, data, name)
  local job_info = jobs[job_id]
  local linenr = vim.fn.line("$")
  if linenr == 1 and #data == 1 and data[#data] == "" then
    return
  end

  if #data > 1 and data[#data] == "" then
    data[#data] = nil
  end
  vim.api.nvim_buf_set_lines(job_info.bufnr, linenr, -1, true, data)
end

function on_stderr(job_id, data, name)
  local linenr = vim.fn.line("$")
  if #data == 1 and data[#data] == "" then
    return
  end

  if #data > 1 and data[#data] == "" then
    data[#data] = nil
  end

  local error_lines = {}
  for index,error in ipairs(data)
  do
    error_lines[index] = "ERROR: " .. error
  end

  local job_info = jobs[job_id]
  vim.api.nvim_buf_set_lines(job_info.bufnr, linenr, -1, true, error_lines)
end

function on_exit(job_id, _data, event)
  local job_info = jobs[job_id]
  vim.api.nvim_buf_set_lines(job_info.bufnr, vim.fn.line("$"), -1, true, {"[firvish] Job Finished..."})
  vim.api.nvim_buf_set_var(bufnr, "firvish_job_id", -1)

  jobs[job_id] = nil
end

M.start_job = function(cmd, filetype, title, use_last_buffer)
  local buf_title = "firvish [" .. title .. "-" .. job_count .. "]"
  local bufnr = -1
  
  if use_last_buffer and vim.api.nvim_buf_get_option(0, "filetype") == filetype then
    bufnr = vim.fn.bufnr()
  elseif use_last_buffer and opened_buffers[filetype] ~= nil then
    bufnr = opened_buffers[filetype]
  end

  if bufnr == -1 or vim.fn.bufexists(bufnr) == 0 then
    bufnr = utils.show_preview(
      buf_title, filetype, {buflisted=true}
      )
    opened_buffers[filetype] = bufnr
    job_count = job_count + 1
  end

  assert(bufnr ~= -1)

  if not use_last_buffer then
    vim.api.nvim_command("buffer " .. bufnr)
  end

  local job_id = vim.fn.jobstart(cmd, {
      on_stderr=on_stderr,
      on_stdout=on_stdout,
      on_exit=on_exit,
      stderr_buffered=false,
      stdout_buffered=false,
      cwd=vim.fn.getcwd(),
      detach=false,
    })

  if job_id == 0 then
    utils.log_error("Invalid arguments were provided to start_job.")
  elseif job_id == -1 then
    utils.log_error("Command or 'shell' is not executable.")
  end

  vim.api.nvim_buf_set_var(bufnr, "firvish_job_id", job_id)
  jobs[job_id] = {bufnr=bufnr}
end

return M
