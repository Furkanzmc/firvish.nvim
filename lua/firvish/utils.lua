local vim = vim
local M = {}

--- Opens a firvish buffer with the given title and filetype.
--- @param title string The title/name of the buffer.
--- @param filetype string The filetype to set for the buffer.
--- @param options table|nil Optional settings like buflisted.
--- @return number bufnr The created buffer number.
M.open_firvish_buffer = function(title, filetype, options)
    vim.cmd.edit(title)
    local bufnr = vim.api.nvim_get_current_buf()

    vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
    vim.api.nvim_set_option_value("readonly", false, { buf = bufnr })

    local buflisted = (options and options.buflisted ~= nil) and options.buflisted or false
    vim.api.nvim_set_option_value("buflisted", buflisted, { buf = bufnr })
    vim.api.nvim_set_option_value("buftype", "nowrite", { buf = bufnr })
    vim.api.nvim_set_option_value("filetype", filetype, { buf = bufnr })

    return bufnr
end

--- Creates a preview window and populates it with lines.
--- @param title string The title for the preview window.
--- @param lines string[] The lines to set in the buffer.
--- @return number bufnr The buffer number of the preview window.
M.create_preview_window = function(title, lines)
    -- Using pedit to open/update the preview window
    -- We escape the title to ensure it's treated as a single filename/buffer name
    vim.cmd.pedit(vim.fn.fnameescape(title))

    -- Find the preview window and its buffer
    local bufnr = -1
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_get_option_value("previewwindow", { win = win }) then
            bufnr = vim.api.nvim_win_get_buf(win)
            break
        end
    end

    if bufnr == -1 then
        -- Fallback if preview window wasn't found
        bufnr = vim.api.nvim_create_buf(false, true)
    end

    vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
    vim.api.nvim_set_option_value("readonly", false, { buf = bufnr })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

    vim.api.nvim_set_option_value("buflisted", false, { buf = bufnr })
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })

    return bufnr
end

--- Sets lines in a buffer while ensuring it's modifiable.
--- @param bufnr number The buffer number.
--- @param lines string[] The lines to set.
M.set_buf_lines = function(bufnr, lines)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end
    local modifiable = vim.api.nvim_get_option_value("modifiable", { buf = bufnr })
    local readonly = vim.api.nvim_get_option_value("readonly", { buf = bufnr })

    if not modifiable then
        vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
    end
    if readonly then
        vim.api.nvim_set_option_value("readonly", false, { buf = bufnr })
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modified", false, { buf = bufnr })

    if not modifiable then
        vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
    end
    if readonly then
        vim.api.nvim_set_option_value("readonly", true, { buf = bufnr })
    end
end

--- Appends lines to a buffer while ensuring it's modifiable.
--- @param bufnr number The buffer number.
--- @param lines string[] The lines to append.
M.append_buf_lines = function(bufnr, lines)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end
    local modifiable = vim.api.nvim_get_option_value("modifiable", { buf = bufnr })
    local readonly = vim.api.nvim_get_option_value("readonly", { buf = bufnr })

    if not modifiable then
        vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
    end
    if readonly then
        vim.api.nvim_set_option_value("readonly", false, { buf = bufnr })
    end

    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, lines)
    vim.api.nvim_set_option_value("modified", false, { buf = bufnr })

    if not modifiable then
        vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
    end
    if readonly then
        vim.api.nvim_set_option_value("readonly", true, { buf = bufnr })
    end
end

--- Jumps to a specific window in a specific tab.
M.jump_to_window = function(tab, window)
    vim.cmd(tab .. "tabnext")
    vim.cmd(window .. "wincmd w")
end

--- Finds the first window containing the given buffer.
--- @param bufnr number The buffer number.
--- @return table {tabnr, winnr}
M.find_open_window = function(bufnr)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == bufnr then
            local tabnr = vim.api.nvim_win_get_tabpage(win)
            -- Convert to 1-based index if needed, but vim.fn.tabpagenr() is usually better for commands
            -- Let's return handle or tabnr as expected by callers
            return {
                tabnr = vim.api.nvim_tabpage_get_number(tabnr),
                winnr = vim.api.nvim_win_get_number(win),
            }
        end
    end
    return { tabnr = -1, winnr = -1 }
end

--- Checks if a buffer is visible in a specific tab.
M.is_window_visible = function(tabnr, bufnr)
    local tab_handle = vim.api.nvim_list_tabpages()[tabnr]
    if not tab_handle then
        return false
    end
    local wins = vim.api.nvim_tabpage_list_wins(tab_handle)
    for _, win in ipairs(wins) do
        if vim.api.nvim_win_get_buf(win) == bufnr then
            return true
        end
    end
    return false
end

--- Predicate helper.
M.any_of = function(items, predicate)
    for _, value in pairs(items) do
        if predicate(value) then
            return true
        end
    end
    return false
end

--- Merges two list-like tables.
M.merge_table = function(target, source)
    vim.list_extend(target, source)
    return target
end

--- Sets the quickfix or location list.
M.set_qflist = function(lines, action, bufnr, extra_efm, use_loclist)
    local efm = vim.api.nvim_get_option_value("errorformat", {})

    extra_efm = extra_efm or {}
    local local_efm = nil
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        local_efm = vim.api.nvim_get_option_value("errorformat", { buf = bufnr })
    end

    if efm ~= "" and local_efm then
        efm = local_efm .. "," .. efm
    elseif local_efm then
        efm = local_efm
    end

    if #extra_efm > 0 then
        efm = table.concat(extra_efm, ",") .. "," .. efm
    end

    local qflist_opts = { lines = lines, efm = efm }
    if use_loclist then
        vim.fn.setloclist(bufnr or 0, {}, action, qflist_opts)
    else
        vim.fn.setqflist({}, action, qflist_opts)
    end
end

--- Wraps two functions into one.
M.wrap = function(f0, f1)
    return function(...)
        f0(...)
        f1(...)
    end
end

return M
