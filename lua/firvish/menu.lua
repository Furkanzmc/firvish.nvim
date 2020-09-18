local vim = vim
local api = vim.api
local cmd = vim.cmd
local fn = vim.api
local M = {}

local utils = require 'firvish.utils'
local buffers = require 'firvish.buffers'

local s_menu_data = {
    Buffers = {
        text = function()
            return "Buffers [" .. buffers.buf_count() .. "]"
        end,
        equals = function(name)
            return string.match(name, "Buffers") ~= nil
        end,
        sub_menu = "buffers"
    },
    History = {
        text = function() return "History" end,
        equals = function(name)
            return string.match(name, "History") ~= nil
        end,
        sub_menu = "history"
    },
    Settings = {
        text = function() return "Settings" end,
        equals = function(name)
            return string.match(name, "Settings") ~= nil
        end,
        sub_menu = "settings"
    }
}

local s_open_bufnr = -1

local function get_menu_items(menu_name)
    local items = {}
    for key, value in pairs(s_menu_data) do
        table.insert(items, "* " .. value.text())
    end

    return items
end

local function get_menu(menu_name)
    for key, menu in pairs(s_menu_data) do
        local asd = menu.equals(menu_name)
        if asd then return menu end
    end

    return nil
end

function M.on_buf_delete() s_open_bufnr = -1 end

function M.on_buf_enter() M.refresh_menu() end

function M.open()
    local tabnr = vim.fn.tabpagenr()

    if vim.fn.bufexists(s_open_bufnr) == 0 then
        vim.api.nvim_command("e firvish://menu")
        s_open_bufnr = vim.fn.bufnr()

        M.refresh_menu()
    elseif utils.is_window_visible(tabnr, s_open_bufnr) then
        vim.api.nvim_command(vim.fn.bufwinnr(s_open_bufnr) .. "wincmd w")
        M.refresh_menu()
    else
        vim.api.nvim_command("buffer " .. s_open_bufnr)
        M.refresh_menu()
    end
end

function M.refresh_menu()
    assert(s_open_bufnr ~= -1, "s_open_bufnr must be valid.")

    local lines = get_menu_items()
    local cursor = vim.api.nvim_win_get_cursor(0)

    utils.set_buf_lines(s_open_bufnr, lines)

    if cursor[1] > #lines then cursor[1] = #lines - 1 end

    if cursor[1] > 0 then vim.api.nvim_win_set_cursor(0, cursor) end
end

function M.open_item(linenr)
    assert(s_open_bufnr ~= -1, "s_open_bufnr must be valid.")

    local lines = api.nvim_buf_get_lines(s_open_bufnr, linenr - 1, linenr, true)
    local menu = get_menu(lines[1])
    cmd("edit " .. "firvish://" .. menu.sub_menu)
end

return M
