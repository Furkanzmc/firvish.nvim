local vim = vim
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt_local = vim.opt_local
local M = {}

local log = require 'firvish.log'
local result, ayar = pcall(require, "ayar")
if result == false then
    function M.init() log.warning("ayar.nvim is not installed.") end
    return M
end

local utils = require 'firvish.utils'

local s_settings_data = {
    firvish_shell = {
        name = function() return "firvish_shell" end,
        value = function() return g.firvish_shell end,
        equals = function(name)
            return string.match(name, "firvish_shell") ~= nil
        end,
        type = "number",
        options = function() return {"1. zsh", "2. pwsh", "3. bash"} end,
        set_option = function(value)
            if value == 1 then
                g.firvish_shell = "zsh"
            elseif value == 2 then
                g.firvish_shell = "pwsh"
            elseif value == 3 then
                g.firvish_shell = "bash"
            else
                log.error("Unkown option: " .. tostring(value))
            end
        end
    }
}

function M.init()
    ayar.init({path = "firvish://settings"})

    for _, setting in pairs(s_settings_data) do ayar.register(setting) end
end

return M
