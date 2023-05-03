local keymap = require("firvish.keymap")
local nnoremap = keymap.nnoremap
local inoremap = keymap.inoremap
local vnoremap = keymap.vnoremap
local xnoremap = keymap.xnoremap
local snoremap = keymap.snoremap
local onoremap = keymap.onoremap

local M = {}

local preview_mappings = {
    n = {
        ["<enter>"] = {
            function()
                require("firvish").open_file_under_cursor("", false, true, false)
            end,
        },
        P = {
            function()
                require("firvish").open_file_under_cursor("", true, true, true)
            end,
        },
        a = {
            function()
                require("firvish").open_file_under_cursor("", true, false, true)
            end,
        },
        o = {
            function()
                require("firvish").open_file_under_cursor("", true, false, false)
            end,
        },
        ["<C-N>"] = {
            function()
                require("firvish").open_file_under_cursor("down", true, true, true)
            end,
        },
        ["<C-P>"] = {
            function()
                require("firvish").open_file_under_cursor("up", true, true, true)
            end,
        },
    },
}

M.config = {
    keymaps = {
        buffers = {
            n = {
                ["<enter>"] = {
                    function()
                        require("firvish.buffers").jump_to_buffer()
                    end,
                },
                ["-"] = {
                    function()
                        vim.cmd("edit firvish://menu")
                    end,
                },
                fa = {
                    function()
                        require("firvish.buffers").filter_buffers("args")
                    end,
                },
                fm = {
                    function()
                        require("firvish.buffers").filter_buffers("modified")
                    end,
                },
                ft = {
                    function()
                        require("firvish.buffers").filter_buffers("current_tab")
                    end,
                },
                R = {
                    function()
                        require("firvish.buffers").refresh_buffers()
                    end,
                },
            },
        },
        dir = preview_mappings,
        history = {
            n = {
                ["<enter>"] = {
                    function()
                        require("firvish.history").open_file()
                    end,
                },
                gq = {
                    function()
                        require("firvish.history").close_history()
                    end,
                },
                R = {
                    function()
                        require("firvish.history").refresh_history()
                    end,
                },
                ["-"] = {
                    function()
                        vim.cmd("edit firvish://menu")
                    end,
                },
            },
        },
        job = preview_mappings,
        ["job-list"] = {
            n = {
                ["<enter>"] = {
                    function()
                        local line = vim.fn.line(".")
                        local lines =
                            vim.api.nvim_buf_get_var(0, "firvish_job_list_additional_lines")
                        require("firvish.job_control").preview_job_output(lines[line].job_id)
                    end,
                },
                dd = {
                    function()
                        require("firvish.job_control").delete_job_from_history(false)
                    end,
                },
                E = {
                    function()
                        local line = vim.fn.line(".")
                        local lines = vim.b.firvish_job_list_additional_lines
                        require("firvish.job_control").echo_job_output(
                            lines[line].job_id,
                            math.max(vim.v.count, 1) * -1
                        )
                    end,
                },
                P = {
                    function()
                        local line = vim.fn.line(".")
                        local lines =
                            vim.api.nvim_buf_get_var(0, "firvish_job_list_additional_lines")
                        require("firvish.job_control").preview_job_output(lines[line].job_id)
                    end,
                },
                R = {
                    function()
                        require("firvish.job_control").refresh_job_list_window()
                    end,
                },
                S = {
                    function()
                        require("firvish.job_control").stop_job()
                    end,
                },
            },
        },
        ["job-output"] = {
            n = {
                gb = {
                    function()
                        require("firvish.job_control").go_back_from_job_output()
                    end,
                },
            },
        },
        menu = {
            n = {
                ["<enter>"] = {
                    function()
                        require("firvish.menu").open_item(vim.fn.line("."))
                    end,
                },
                R = {
                    function()
                        require("firvish.menu").refresh_menu()
                    end,
                },
            },
        },
    },
}

M.apply_mappings = function(map)
    local config = M.config
    for lhs, opts in pairs(config.keymaps[map].n or {}) do
        if opts then
            nnoremap({ lhs, opts[1], buffer = true, silent = true })
        end
    end
    for lhs, opts in pairs(config.keymaps[map].i or {}) do
        if opts then
            inoremap({ lhs, opts[1], buffer = true, silent = true })
        end
    end
    for lhs, opts in pairs(config.keymaps[map].v or {}) do
        if opts then
            vnoremap({ lhs, opts[1], buffer = true, silent = true })
        end
    end
    for lhs, opts in pairs(config.keymaps[map].x or {}) do
        if opts then
            xnoremap({ lhs, opts[1], buffer = true, silent = true })
        end
    end
    for lhs, opts in pairs(config.keymaps[map].s or {}) do
        if opts then
            snoremap({ lhs, opts[1], buffer = true, silent = true })
        end
    end
    for lhs, opts in pairs(config.keymaps[map].o or {}) do
        if opts then
            onoremap({ lhs, opts[1], buffer = true, silent = true })
        end
    end
end

M.merge = function(opts)
    local config = M.config
    M.config = vim.tbl_deep_extend("force", config, opts)
    return config
end

return M
