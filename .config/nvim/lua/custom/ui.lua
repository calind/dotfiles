local _M = {
    borders = {
        heavy = { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' },
        textualize = { '🮇', '▔', '▎', '▎', '▎', '▁', '🮇', '🮇' },
        box = { '􀀁', '􀀄', '􀀂', '􀀆', '􀀃', '􀀅', '􀀀', '􀀇' },
    },
    signs = { Error = '●', Warn = '▲', Hint = '■', Info = '◆', OK = '✔', Loading = '', LightBulb = '' },
    listchars = { tab = '▸ ', trail = '•', extends = '❯', precedes = '❮' },
    fillchars = {
        eob = ' ', -- do not clutter empty space
        vert = '▐',
        horiz = '▂',
        vertright = '▐',
        vertleft = '▐',
        verthoriz = '▐',
        horizup = '▐',
        horizdown = '▂',
        foldclose = '▸',
        foldopen = '▾',
        foldsep = '┃',
    },
    lspkind = {
        Text = '󰉿',
        Method = '󰆧',
        Function = '󰊕',
        Constructor = '',
        Field = '󰜢',
        Variable = '󰀫',
        Class = '󰠱',
        Interface = '',
        Module = '',
        Property = '󰜢',
        Unit = '󰑭',
        Value = '󰎠',
        Enum = '',
        Keyword = '󰌋',
        Snippet = '',
        Color = '󰝤',
        File = '󰈙',
        Reference = '󰈇',
        Folder = '󰉋',
        EnumMember = '',
        Constant = '󰏿',
        Struct = '󰙅',
        Event = '',
        Operator = '󰆕',
        TypeParameter = '',
        Copilot = '',
    },
}

function _M.cmp_format(entry, vim_item)
    if pcall(require, 'tailwind-tools.cmp') then
        vim_item = require('tailwind-tools.cmp').lspkind_format(entry, vim_item)
    end

    local kind = vim_item.kind
    local symbol = _M.lspkind[kind]
    local maxwidth = 150
    local ellipsis = '...'

    if vim.fn.strchars(vim_item.abbr) > maxwidth then
        vim_item.abbr = vim.fn.strcharpart(vim_item.abbr, 0, maxwidth) .. ellipsis
    end

    vim_item.kind = (symbol and symbol .. ' ' or '') .. ' ' .. kind
    return vim_item
end

function _M.setup()
    local au = vim.api.nvim_create_autocmd
    local signs = _M.signs
    local fillchars = _M.fillchars
    local listchars = _M.listchars

    _M.border = _M.borders.box           -- use box border

    vim.opt.cursorline = true            -- highlight the line of the cursor ...
    vim.opt.cursorlineopt = { 'number' } -- ... but only when showing line numbers
    vim.opt.textwidth = 120              -- 120 columns by default
    vim.opt.colorcolumn = '0'            -- show vertical line after textwidth
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.foldcolumn = 'auto:9'
    if vim.fn.has('nvim-0.9') == 1 then
        vim.opt.statuscolumn = [[ %{ v:relnum == 0 ? v:lnum : '' } %=%{v:relnum ? v:relnum : '' } %s%C]]
        au('BufEnter', {
            callback = function()
                if vim.bo.buftype ~= '' then
                    vim.opt_local.statuscolumn = ''
                end
            end
        })
    else
        vim.opt.signcolumn = 'number' -- always show the sign column on nvim < 0.9
    end
    vim.opt.lazyredraw = true         -- redraw only when we need to.
    vim.opt.title = true              -- automatically set window title
    vim.opt.termguicolors = true      -- enable 24bit colors
    vim.opt.fillchars:append(fillchars)
    vim.opt.list = true
    vim.opt.showbreak = '↪ '

    -- Build diagnostic signs according to the signs table.
    for kind, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. kind
        vim.fn.sign_define(hl, { text = icon, texthl = hl })
    end
    vim.fn.sign_define('LightBulbSign', { text = signs.LightBulb, texthl = 'LightBulbSign', numhl = 'LightBulbSign' })

    -- Show listchars, except for tailing whitespace which is shown only on normal mode.
    au('BufEnter', {
        callback = function()
            vim.opt_local.listchars = vim.b.listchars or listchars
        end
    })
    au('InsertEnter', { callback = function() vim.opt_local.listchars:remove('trail') end })
    au('InsertLeave', { callback = function() vim.opt_local.listchars:append({ trail = listchars.trail }) end })

    au('TextYankPost', {
        desc = 'Highlight when yanking text',
        callback = function()
            vim.highlight.on_yank()
        end,
    })
end

return _M
