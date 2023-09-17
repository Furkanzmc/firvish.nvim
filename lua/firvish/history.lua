local vim = vim
local M = {}
local utils = require("firvish.utils")

local g_open_buffer = 0
local g_previous_bufnr = 0

local function get_history(predicate)
    local old_files = vim.api.nvim_get_vvar("oldfiles")
    local history = {}
    for _, file in ipairs(old_files) do
        if
            vim.fn.filereadable(file) == 1
            and (predicate == nil or (predicate ~= nil and predicate(file) == true))
        then
            history[#history + 1] = vim.fn.fnamemodify(file, ":p:~:.")
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
    if g_previous_bufnr ~= 0 then
        vim.api.nvim_command("buffer " .. g_previous_bufnr)
    else
        vim.api.nvim_command("bwipeout! " .. g_open_buffer)
        g_open_buffer = 0
    end

    g_previous_bufnr = 0
end

M.open_history = function()
    local tabnr = vim.fn.tabpagenr()
    g_previous_bufnr = vim.fn.bufnr()

    if g_open_buffer == 0 then
        vim.api.nvim_command("e firvish://history")
        g_open_buffer = vim.fn.bufnr()
        M.refresh_history()
    elseif utils.is_window_visible(tabnr, g_open_buffer) then
        vim.api.nvim_command(vim.fn.bufwinnr(g_open_buffer) .. "wincmd w")
        M.refresh_history()
    else
        vim.api.nvim_command("buffer " .. g_open_buffer)
        M.refresh_history()
    end
end

M.refresh_history = function()
    utils.set_buf_lines(g_open_buffer, get_history(nil))
end

M.open_file = function()
    local linenr = vim.fn.line(".")
    local lines = vim.api.nvim_buf_get_lines(g_open_buffer, linenr - 1, linenr, true)
    vim.api.nvim_command("edit " .. lines[1])
end

return M
