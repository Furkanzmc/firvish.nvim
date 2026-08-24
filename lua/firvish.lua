local vim = vim
local utils = require("firvish.utils")
local log = require("firvish.log")
local M = {}

local function run_commands(bufnr, sh_mode)
    if sh_mode == true then
        local ok, shell = pcall(vim.api.nvim_get_var, "firvish_shell")
        if not ok then
            shell = vim.o.shell
        end
        local cmd = { shell }
        if string.match(shell, "powershell") ~= nil or string.match(shell, "pwsh") ~= nil then
            vim.list_extend(cmd, {
                "-NoLogo",
                "-NonInteractive",
                "-NoProfile",
                "-ExecutionPolicy",
                "RemoteSigned",
                "-File",
            })
        end

        table.insert(cmd, vim.fn.expand("%"))
        require("firvish.job_control").start_job({
            cmd = cmd,
            filetype = "firvish-job",
            title = "fhdo",
            use_last_buffer = false,
            is_background_job = false, -- simplified
            listed = true,
        })
        vim.api.nvim_buf_delete(bufnr, { force = true })
    else
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
        vim.cmd.wincmd("p")
        vim.api.nvim_buf_delete(bufnr, { force = true })

        for _, line in ipairs(lines) do
            vim.cmd(line)
        end
    end
end

--- @param line1 integer
--- @param line2 integer
--- @param source_buffer integer
--- @param cmd_template string
--- @param sh_mode boolean
M.open_linedo_buffer = function(line1, line2, source_buffer, cmd_template, sh_mode)
    local lines = vim.api.nvim_buf_get_lines(source_buffer, line1 - 1, line2, true)
    local ok, shell = pcall(vim.api.nvim_get_var, "firvish_shell")
    if not ok then
        shell = vim.o.shell
    end
    local extension = "sh"

    if sh_mode == false then
        extension = "vim"
    elseif string.match(shell, "powershell") ~= nil or string.match(shell, "pwsh") ~= nil then
        extension = "ps1"
    elseif string.match(shell, "cmd") ~= nil then
        extension = "bat"
    end

    vim.cmd.split({ args = { vim.fn.tempname() .. "." .. extension }, mods = { silent = true } })
    local bufnr = vim.api.nvim_get_current_buf()

    local command_lines = {}
    for _, line in ipairs(lines) do
        table.insert(command_lines, (string.gsub(cmd_template, "{}", '"' .. line .. '"')))
    end

    vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
    vim.api.nvim_set_option_value("readonly", false, { buf = bufnr })
    vim.api.nvim_set_option_value("buflisted", false, { buf = bufnr })
    vim.api.nvim_set_option_value("cursorline", true, { win = 0 })

    vim.keymap.set("n", "E!", function()
        vim.cmd("silent write")
        run_commands(vim.api.nvim_get_current_buf(), sh_mode)
    end, { noremap = true, buffer = bufnr })

    utils.set_buf_lines(bufnr, command_lines)
    vim.cmd.write()

    return bufnr
end

M.open_file_under_cursor = function(nav_direction, preview, reuse_window, vertical)
    if reuse_window then
        local current_win = vim.api.nvim_get_current_win()
        vim.cmd.wincmd("l")
        if vim.api.nvim_get_current_win() ~= current_win then
            vim.cmd.close()
        end
    end

    local cmd = "^F"
    if vertical then
        vim.cmd("vertical normal " .. cmd)
    else
        vim.cmd("normal " .. cmd)
    end

    if preview then
        vim.cmd.wincmd("p")
    end

    if nav_direction == "down" then
        vim.cmd.normal({ args = { "j" }, bang = true })
    elseif nav_direction == "up" then
        vim.cmd.normal({ args = { "k" }, bang = true })
    end
end

M.setup = function(opts)
    require("firvish.config").merge(opts or {})
end

return M
