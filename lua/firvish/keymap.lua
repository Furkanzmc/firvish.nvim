-- NOTE: (mostly) copied from astronauta.nvim
-- See: https://github.com/neovim/neovim/pull/13823
local keymap = {}

__FirvishMapStore = __FirvishMapStore or {}
keymap._store = __FirvishMapStore

keymap._create = function(f)
    table.insert(keymap._store, f)
    return #keymap._store
end

keymap._execute = function(id)
    return keymap._store[id]()
end

keymap._expr = function(id)
    return vim.api.nvim_replace_termcodes(keymap._store[id](), true, true, true)
end

local make_mapper = function(mode, defaults, opts)
    local args, map_args = {}, {}
    for k, v in pairs(opts) do
        if type(k) == "number" then
            args[k] = v
        else
            map_args[k] = v
        end
    end

    local lhs = opts.lhs or args[1]
    local rhs = opts.rhs or args[2]
    local map_opts = vim.tbl_extend("force", defaults, map_args)

    local mapping
    if type(rhs) == "string" then
        mapping = rhs
    elseif type(rhs) == "function" then
        local func_id = keymap._create(rhs)

        if map_opts.expr then
            mapping = string.format([[luaeval("require("firvish.keymap")._expr(%s)")]], func_id)
        else
            assert(
                map_opts.noremap,
                "If `rhs` is a function and it's not an expr, `opts.noremap` must be true"
            )
            mapping =
                string.format([[<cmd>lua require("firvish.keymap")._execute(%s)<CR>]], func_id)
        end
    else
        error("Unexpected type for rhs:" .. tostring(rhs))
    end

    if not map_opts.buffer then
        vim.api.nvim_set_keymap(mode, lhs, mapping, map_opts)
    else
        -- Clear the buffer after saving it
        local buffer = map_opts.buffer
        if buffer == true then
            buffer = 0
        end

        map_opts.buffer = nil

        vim.api.nvim_buf_set_keymap(buffer, mode, lhs, mapping, map_opts)
    end
end

function keymap.map(opts)
    return make_mapper("", { noremap = false }, opts)
end

function keymap.noremap(opts)
    return make_mapper("", { noremap = true }, opts)
end

function keymap.nmap(opts)
    return make_mapper("n", { noremap = false }, opts)
end

function keymap.nnoremap(opts)
    return make_mapper("n", { noremap = true }, opts)
end

function keymap.vmap(opts)
    return make_mapper("v", { noremap = false }, opts)
end

function keymap.vnoremap(opts)
    return make_mapper("v", { noremap = true }, opts)
end

function keymap.xmap(opts)
    return make_mapper("x", { noremap = false }, opts)
end

function keymap.xnoremap(opts)
    return make_mapper("x", { noremap = true }, opts)
end

function keymap.smap(opts)
    return make_mapper("s", { noremap = false }, opts)
end

function keymap.snoremap(opts)
    return make_mapper("s", { noremap = true }, opts)
end

function keymap.omap(opts)
    return make_mapper("o", { noremap = false }, opts)
end

function keymap.onoremap(opts)
    return make_mapper("o", { noremap = true }, opts)
end

function keymap.imap(opts)
    return make_mapper("i", { noremap = false }, opts)
end

function keymap.inoremap(opts)
    return make_mapper("i", { noremap = true }, opts)
end

function keymap.lmap(opts)
    return make_mapper("l", { noremap = false }, opts)
end

function keymap.lnoremap(opts)
    return make_mapper("l", { noremap = true }, opts)
end

function keymap.cmap(opts)
    return make_mapper("c", { noremap = false }, opts)
end

function keymap.cnoremap(opts)
    return make_mapper("c", { noremap = true }, opts)
end

function keymap.tmap(opts)
    return make_mapper("t", { noremap = false }, opts)
end

function keymap.tnoremap(opts)
    return make_mapper("t", { noremap = true }, opts)
end

return keymap
