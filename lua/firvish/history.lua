local vim = vim
local M = {}
local utils = require("firvish.utils")

local g_open_buffer = 0
local g_previous_bufnr = 0

local function get_history(predicate)
    local old_files = vim.v.oldfiles
    local history = {}
    for _, file in ipairs(old_files) do
        if
            vim.fn.filereadable(file) == 1
            and (predicate == nil or predicate(file))
        then
            table.insert(history, vim.fn.fnamemodify(file, ":p:~:."))
        end
    end

    return history
end

M.on_buf_delete = function()
    g_open_buffer = 0
end

M.on_buf_leave = function()
    g_previous_bufnr = 0
end

M.close_history = function()
    if g_previous_bufnr ~= 0 and vim.api.nvim_buf_is_valid(g_previous_bufnr) then
        vim.cmd.buffer(g_previous_bufnr)
    elseif g_open_buffer ~= 0 and vim.api.nvim_buf_is_valid(g_open_buffer) then
        vim.api.nvim_buf_delete(g_open_buffer, { force = true })
        g_open_buffer = 0
    end

    g_previous_bufnr = 0
end

M.open_history = function()
    local tabnr = vim.fn.tabpagenr()
    g_previous_bufnr = vim.api.nvim_get_current_buf()

    if g_open_buffer == 0 or not vim.api.nvim_buf_is_valid(g_open_buffer) then
        vim.cmd.edit("firvish://history")
        g_open_buffer = vim.api.nvim_get_current_buf()
        M.refresh_history()
    elseif utils.is_window_visible(tabnr, g_open_buffer) then
        local win = vim.fn.bufwinid(g_open_buffer)
        if win ~= -1 then
            vim.api.nvim_set_current_win(win)
        end
        M.refresh_history()
    else
        vim.cmd.buffer(g_open_buffer)
        M.refresh_history()
    end
end

M.refresh_history = function()
    if g_open_buffer ~= 0 and vim.api.nvim_buf_is_valid(g_open_buffer) then
        utils.set_buf_lines(g_open_buffer, get_history(nil))
    end
end

M.open_file = function()
    local linenr = vim.fn.line(".")
    local lines = vim.api.nvim_buf_get_lines(g_open_buffer, linenr - 1, linenr, true)
    if #lines > 0 then
        vim.cmd.edit(lines[1])
    end
end

return M
