local vim = vim
local M = {}

M.show_preview = function(title, filetype)
    local bufnr = vim.api.nvim_create_buf(true, true)

    vim.api.nvim_command("buffer " .. bufnr)
    vim.api.nvim_command("file " .. title)

    vim.api.nvim_buf_set_option(".", "modifiable", true)
    vim.api.nvim_buf_set_option(".", "readonly", false)
    vim.api.nvim_command("setlocal cursorline")

    vim.api.nvim_buf_set_option(".", "buflisted", false)
    vim.api.nvim_buf_set_option(".", "buftype", "nowrite")
    vim.api.nvim_buf_set_option(".", "filetype", "firvish")

    return bufnr
end

M.set_lines = function(bufnr, lines)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
end


M.jump_to_window = function(tab, window)
    vim.api.nvim_command(tab .. 'tabnext')
    vim.api.nvim_command(window .. 'wincmd w')
end


M.find_open_window = function(buffer)
    local current_tab = vim.fn.tabpagenr()
    local last_tab = vim.fn.tabpagenr('$')
    for tabnr=1,last_tab,1
    do
        local buffers = vim.fn.tabpagebuflist(tabnr)
        for winnr,bufnr in ipairs(buffers)
        do
            if buffer == bufnr then
                return {tabnr=tabnr, winnr=winnr}
            end
        end
    end

    return {tabnr=-1, winnr=-1}
end

return M
