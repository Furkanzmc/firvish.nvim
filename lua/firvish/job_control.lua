local vim = vim
local M = {}
local utils = require'firvish.utils'

local jobs = {}
local job_count = 1

function on_stdout(job_id, data, name)
  local job_info = jobs[job_id]
  vim.api.nvim_buf_set_lines(job_info.bufnr, 0, -1, true, data)
end

function on_stderr(job_id, data, name)
  if data[1] == "" then
    return
  end

  local error_lines = {}
  for index,error in ipairs(data)
  do
    error_lines[index] = "[firvish-error] - " .. error
  end

  local job_info = jobs[job_id]
  vim.api.nvim_buf_set_lines(job_info.bufnr, -1, -1, true, error_lines)
end

function on_exit(job_id, _data, event)
  local job_info = jobs[job_id]
  vim.api.nvim_buf_set_lines(job_info.bufnr, -1, -1, true, {"[firvish] Job Finished..."})
  jobs[job_id] = -1
end

M.start_job = function(cmd, filetype)
  local bufnr = utils.show_preview("neovim-firvish [job-" .. job_count .. "]", filetype)
  job_count = job_count + 1
  vim.api.nvim_command("buffer " .. bufnr)

  local job_id = vim.fn.jobstart(cmd, {
      on_stderr=on_stderr,
      on_stdout=on_stdout,
      on_exit=on_exit,
      stderr_buffered=true,
      stdout_buffered=true,
    })

  jobs[job_id] = {bufnr=bufnr}
end

return M
