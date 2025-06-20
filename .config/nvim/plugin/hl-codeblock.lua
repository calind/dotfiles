-- place marks at the beginning and the end of treesitter codeblocks

local enabled_langs = { help = true }
local ns = vim.api.nvim_create_namespace('codeblock')

local function clear_marks()
    local buf = vim.api.nvim_get_current_buf()
    local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
    for _, mark in ipairs(marks) do
        vim.api.nvim_buf_del_extmark(buf, ns, mark[1])
    end
end

local function place_marks()
    local lang = vim.bo.filetype
    if not enabled_langs[lang] then return end

    local readonly = vim.bo.readonly
    local buf = vim.api.nvim_get_current_buf()
    local ok, parser = pcall(vim.treesitter.get_parser, buf, lang)
    if not ok then return end

    local highlighter = require('vim.treesitter.highlighter')
    local hl = highlighter.active[buf]
    if not hl then
        return
    end
    local query = vim.treesitter.query.get(lang, 'highlights')

    if not readonly then
        clear_marks()
    end
    for _, tree in ipairs(parser:trees()) do
        for capture_id, node, _ in query:iter_captures(tree:root(), 0) do
            local name              = query.captures[capture_id]
            local line, col         = node:start()
            local end_line, end_col = node:end_()
            if name == 'markup.raw.block' then
                vim.api.nvim_buf_set_extmark(buf, ns, line, col, {
                    end_line = end_line,
                    end_col = end_col,
                    hl_group = '@markup.raw.block',
                    hl_eol = true,
                })
            end
        end
    end
end
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinNew' }, { callback = place_marks })
-- vim.api.nvim_create_autocmd({ 'CursorHold', 'TextChangedI' }, { callback = place_marks })
