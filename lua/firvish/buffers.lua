local vim = vim
local M = {}
local utils = require("firvish.utils")
local log = require("firvish.log")

local s_open_bufnr = -1
local s_buffer_list_dirty = true
local s_cached_buffers = {}
local s_buffers_filtered = false

local function create_buffer_list(predicate)
    if s_buffer_list_dirty == false then
        return s_cached_buffers
    end

    local buffers = {}
    local all_buffers = vim.api.nvim_list_bufs()
    
    -- Filter listed buffers
    local listed_buffers = {}
    for _, bufnr in ipairs(all_buffers) do
        if vim.api.nvim_get_option_value("buflisted", { buf = bufnr }) then
            table.insert(listed_buffers, bufnr)
        end
    end

    local buf_num_length = #tostring(#listed_buffers)

    for _, bufnr in ipairs(listed_buffers) do
        if
            bufnr ~= s_open_bufnr
            and (predicate == nil or predicate(bufnr))
        then
            local bufnr_str = "[" .. bufnr .. "]"
            local line = bufnr_str
            local modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })
            local bufname = vim.api.nvim_buf_get_name(bufnr)
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

            table.insert(buffers, line)
        end
    end

    s_cached_buffers = buffers
    s_buffer_list_dirty = false
    return s_cached_buffers
end

local function get_bufnr(linenr)
    local lines = vim.api.nvim_buf_get_lines(s_open_bufnr, linenr - 1, linenr, false)
    if #lines == 0 then return -1 end
    local line = lines[1]
    
    local bufnr_match = string.match(line, "%[(%d+)%]")
    if bufnr_match then
        return tonumber(bufnr_match)
    end

    local buffer_name = string.match(line, "%s+(.*)$")
    if buffer_name then
        buffer_name = vim.trim(buffer_name)
        local bufnr = vim.fn.bufnr(buffer_name)
        if bufnr ~= -1 then
            return bufnr
        end
    end

    log.error("Cannot read buffer number from the list.")
    return -1
end

M.on_buf_delete = function()
    s_open_bufnr = -1
end

M.on_buf_enter = function()
    if not s_buffers_filtered then
        M.open_buffers()
    end
end

M.on_buf_leave = function() end

M.mark_dirty = function()
    s_buffer_list_dirty = true
end

M.jump_to_buffer = function()
    local bufnr = get_bufnr(vim.fn.line("."))
    if bufnr == -1 then
        return
    end

    local jump_info = utils.find_open_window(bufnr)
    if jump_info.tabnr ~= -1 and jump_info.winnr ~= -1 then
        utils.jump_to_window(jump_info.tabnr, jump_info.winnr)
    else
        vim.cmd.buffer(bufnr)
    end
end

M.open_buffers = function()
    local tabnr = vim.fn.tabpagenr()

    if s_open_bufnr == -1 or not vim.api.nvim_buf_is_valid(s_open_bufnr) then
        vim.cmd.edit("firvish://buffers")
        s_open_bufnr = vim.api.nvim_get_current_buf()
        M.refresh_buffers()
    elseif utils.is_window_visible(tabnr, s_open_bufnr) then
        local win = vim.fn.bufwinid(s_open_bufnr)
        if win ~= -1 then
            vim.api.nvim_set_current_win(win)
        end
        M.refresh_buffers()
    else
        vim.cmd.buffer(s_open_bufnr)
        M.refresh_buffers()
    end
end

M.refresh_buffers = function()
    if s_open_bufnr == -1 or not vim.api.nvim_buf_is_valid(s_open_bufnr) then
        return
    end

    s_buffer_list_dirty = true
    s_buffers_filtered = false
    local lines = create_buffer_list()
    local cursor = vim.api.nvim_win_get_cursor(0)
    utils.set_buf_lines(s_open_bufnr, lines)

    if cursor[1] > #lines and #lines > 0 then
        cursor[1] = #lines
    end

    if cursor[1] > 0 then
        pcall(vim.api.nvim_win_set_cursor, 0, cursor)
    end
end

M.filter_buffers = function(mode)
    local buffers = nil
    s_buffer_list_dirty = true
    if mode == "modified" then
        buffers = create_buffer_list(function(bufnr)
            return vim.api.nvim_get_option_value("modified", { buf = bufnr })
        end)
    elseif mode == "current_tab" then
        local tabnr = vim.fn.tabpagenr()
        buffers = create_buffer_list(function(bufnr)
            return utils.is_window_visible(tabnr, bufnr)
        end)
    elseif mode == "args" then
        local args = vim.fn.argv()
        local args_bufnr = {}
        for _, arg in ipairs(args) do
            local b = vim.fn.bufnr(arg)
            if b ~= -1 then
                args_bufnr[b] = true
            end
        end

        buffers = create_buffer_list(function(bufnr)
            return args_bufnr[bufnr] == true
        end)
    elseif type(mode) == "function" then
        buffers = create_buffer_list(mode)
    else
        error("Unsupported filter type: " .. tostring(mode))
    end

    utils.set_buf_lines(s_open_bufnr, buffers)
    s_buffers_filtered = true
end

M.buf_do = function(start_line, end_line, cmd)
    local current_buf = vim.api.nvim_get_current_buf()
    for linenr = start_line, end_line, 1 do
        local bufnr = get_bufnr(linenr)
        if bufnr ~= -1 then
            vim.cmd.buffer(bufnr)
            vim.cmd(cmd)
        end
    end

    vim.cmd.buffer(current_buf)
end

M.buf_delete = function(start_line, end_line, force)
    for linenr = start_line, end_line, 1 do
        local bufnr = get_bufnr(linenr)
        if bufnr ~= -1 then
            vim.api.nvim_buf_delete(bufnr, { force = force })
        end
    end

    M.refresh_buffers()
end

M.buf_count = function()
    local buffers = create_buffer_list()
    return #buffers
end

return M
