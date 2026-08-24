local keymap = vim.keymap

local M = {}

local preview_mappings = {
    n = {
        ["<enter>"] = function()
            require("firvish").open_file_under_cursor("", false, true, false)
        end,
        P = function()
            require("firvish").open_file_under_cursor("", true, true, true)
        end,
        a = function()
            require("firvish").open_file_under_cursor("", true, false, true)
        end,
        o = function()
            require("firvish").open_file_under_cursor("", true, false, false)
        end,
        ["<C-N>"] = function()
            require("firvish").open_file_under_cursor("down", true, true, true)
        end,
        ["<C-P>"] = function()
            require("firvish").open_file_under_cursor("up", true, true, true)
        end,
    },
}

M.config = {
    keymaps = {
        buffers = {
            n = {
                ["<enter>"] = function()
                    require("firvish.buffers").jump_to_buffer()
                end,
                fa = function()
                    require("firvish.buffers").filter_buffers("args")
                end,
                fm = function()
                    require("firvish.buffers").filter_buffers("modified")
                end,
                ft = function()
                    require("firvish.buffers").filter_buffers("current_tab")
                end,
                R = function()
                    require("firvish.buffers").refresh_buffers()
                end,
            },
        },
        dir = preview_mappings,
        history = {
            n = {
                ["<enter>"] = function()
                    require("firvish.history").open_file()
                end,
                gq = function()
                    require("firvish.history").close_history()
                end,
                R = function()
                    require("firvish.history").refresh_history()
                end,
            },
        },
        job = preview_mappings,
        ["job-list"] = {
            n = {
                ["<enter>"] = function()
                    local line = vim.fn.line(".")
                    local ok, lines = pcall(vim.api.nvim_buf_get_var, 0, "firvish_job_list_additional_lines")
                    if ok and lines[line] then
                        require("firvish.job_control").preview_job_output(lines[line].job_id)
                    end
                end,
                dd = function()
                    require("firvish.job_control").delete_job_from_history(false)
                end,
                E = function()
                    local line = vim.fn.line(".")
                    local lines = vim.b.firvish_job_list_additional_lines
                    if lines and lines[line] then
                        require("firvish.job_control").echo_job_output(
                            lines[line].job_id,
                            math.max(vim.v.count, 1) * -1
                        )
                    end
                end,
                P = function()
                    local line = vim.fn.line(".")
                    local ok, lines = pcall(vim.api.nvim_buf_get_var, 0, "firvish_job_list_additional_lines")
                    if ok and lines[line] then
                        require("firvish.job_control").preview_job_output(lines[line].job_id)
                    end
                end,
                R = function()
                    require("firvish.job_control").refresh_job_list_window()
                end,
                S = function()
                    require("firvish.job_control").stop_job()
                end,
            },
        },
        ["job-output"] = {
            n = {
                gb = function()
                    require("firvish.job_control").go_back_from_job_output()
                end,
            },
        },
    },
}

M.internal = {
    apply_mappings = function(map_name)
        local map_config = M.config.keymaps[map_name]
        if not map_config then
            return
        end

        for mode, mappings in pairs(map_config) do
            for lhs, rhs in pairs(mappings) do
                keymap.set(mode, lhs, rhs, { noremap = true, buffer = true, silent = true })
            end
        end
    end,
}

M.merge = function(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts)
    return M.config
end

return M
