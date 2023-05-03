local vim = vim
local M = {}
local utils = require("firvish.utils")

local open_bufnr = nil

function get_history(predicate)
    local old_files = vim.api.nvim_get_vvar("oldfiles")
    local history = {}
    for index, file in ipairs(old_files) do
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
    open_bufnr = nil
end

M.on_buf_leave = function()
    previous_bufnr = nil
end

M.close_history = function()
    if previous_bufnr ~= nil then
        vim.api.nvim_command("buffer " .. previous_bufnr)
    else
        vim.api.nvim_command("bwipeout! " .. open_bufnr)
        open_bufnr = nil
    end

    previous_bufnr = nil
end

M.open_history = function()
    local tabnr = vim.fn.tabpagenr()
    previous_bufnr = vim.fn.bufnr()

    if open_bufnr == nil then
        vim.api.nvim_command("e firvish://history")
        open_bufnr = vim.fn.bufnr()
        M.refresh_history()
    elseif utils.is_window_visible(tabnr, open_bufnr) then
        vim.api.nvim_command(vim.fn.bufwinnr(open_bufnr) .. "wincmd w")
        M.refresh_history()
    else
        vim.api.nvim_command("buffer " .. open_bufnr)
        M.refresh_history()
    end
end

M.refresh_history = function()
    utils.set_buf_lines(open_bufnr, get_history(nil))
end

M.open_file = function()
    local linenr = vim.fn.line(".")
    local lines = vim.api.nvim_buf_get_lines(open_bufnr, linenr - 1, linenr, true)
    vim.api.nvim_command("edit " .. lines[1])
end

return M
