local vim = vim
local utils = require("firvish.utils")
local log = require("firvish.log")
local M = {}

local options_loaded, options = pcall(require, "options")
if not options_loaded then
    log.warning("options.nvim is not installed. See `:help firvish.txt` for disabled features.")
end

if options_loaded then
    options.register_option({
        name = "alwayspreview",
        type_info = "boolean",
        description = "When set to true, the output of the running job will be shown in previewwindow.",
        default = false,
        source = "firvish",
        global = true,
    })
end

local function run_commands(bufnr, sh_mode)
    if sh_mode == true then
        local shell = vim.api.nvim_get_var("firvish_shell")
        local cmd = { shell }
        if string.match(shell, "powershell") ~= nil or string.match(shell, "pwsh") ~= nil then
            table.insert(cmd, "-NoLogo")
            table.insert(cmd, "-NonInteractive")
            table.insert(cmd, "-NoProfile")
            table.insert(cmd, "-ExecutionPolicy")
            table.insert(cmd, "RemoteSigned")
            table.insert(cmd, "-File")
        end

        table.insert(cmd, vim.fn.expand("%"))
        require("firvish.job_control").start_job({
            cmd = cmd,
            filetype = "firvish-job",
            title = "fhdo",
            use_last_buffer = false,
            is_background_job = "<bang>" == "!",
            listed = true,
        })
        vim.api.nvim_command("bwipeout! " .. bufnr)
    else
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
        vim.api.nvim_command("wincmd p")
        vim.api.nvim_command("bwipeout! " .. bufnr)

        for _, line in pairs(lines) do
            vim.api.nvim_command(line)
        end
    end
end

--- @param line1 integer
--- @param line2 integer
--- @param source_buffer integer
--- @param cmd string
--- @param sh_mode boolean
M.open_linedo_buffer = function(line1, line2, source_buffer, cmd, sh_mode)
    local lines = vim.api.nvim_buf_get_lines(source_buffer, line1 - 1, line2, true)
    local shell = vim.api.nvim_get_var("firvish_shell")
    local extension = "sh"

    if sh_mode == false then
        extension = "vim"
    elseif string.match(shell, "powershell") ~= nil or string.match(shell, "pwsh") ~= nil then
        extension = "ps1"
    elseif string.match(shell, "cmd") ~= nil then
        extension = "bat"
    end

    vim.api.nvim_command("silent split " .. vim.fn.tempname() .. "." .. extension)
    local bufnr = vim.fn.bufnr()

    local command_lines = {}
    for index, line in pairs(lines) do
        command_lines[index] = string.gsub(cmd, "{}", '"' .. line .. '"')
    end

    vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
    vim.api.nvim_buf_set_option(bufnr, "readonly", false)
    vim.api.nvim_buf_set_option(bufnr, "buflisted", false)

    vim.api.nvim_command("setlocal cursorline")

    vim.keymap.set("n", "E!", function()
        vim.cmd("silent write")
        run_commands(vim.fn.bufnr(), sh_mode)
    end, { noremap = true, buffer = true })

    utils.set_buf_lines(bufnr, command_lines)
    vim.api.nvim_command("write")

    return bufnr
end

M.open_file_under_cursor = function(nav_direction, preview, reuse_window, vertical)
    if reuse_window then
        local current_winnr = vim.fn.winnr()
        vim.api.nvim_command("wincmd l")
        if vim.fn.winnr() ~= current_winnr then
            vim.api.nvim_command("normal q")
        end
    end

    if vertical then
        vim.api.nvim_command("vertical normal ^F")
    else
        vim.api.nvim_command("normal ^F")
    end

    if preview then
        vim.api.nvim_command("wincmd p")
    end

    if nav_direction == "down" then
        vim.api.nvim_command("normal j")
    elseif nav_direction == "up" then
        vim.api.nvim_command("normal k")
    end
end

M.setup = function(opts)
    require("firvish.config").merge(opts or {})
end

return M
