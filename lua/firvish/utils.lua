local vim = vim
local M = {}

M.show_preview = function(title, filetype, options)
    local bufnr = vim.api.nvim_create_buf(true, true)

    vim.api.nvim_command("buffer " .. bufnr)
    vim.api.nvim_command("file " .. title)

    vim.api.nvim_buf_set_option(".", "modifiable", true)
    vim.api.nvim_buf_set_option(".", "readonly", false)
    vim.api.nvim_command("setlocal cursorline")

    if options ~= nil and options.buflisted ~= nil then
        vim.api.nvim_buf_set_option(".", "buflisted", options.buflisted)
    else
        vim.api.nvim_buf_set_option(".", "buflisted", false)
    end

    vim.api.nvim_buf_set_option(".", "buftype", "nowrite")
    vim.api.nvim_buf_set_option(".", "filetype", filetype)

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

M.is_window_visible = function(tabnr, bufnr)
  local buffers = vim.fn.tabpagebuflist(tabnr)
  for _,win in pairs(buffers)
  do
    if win == bufnr then
      return true
    end
  end

  return false
end

return M
