-- Minimal configuration for Neovim
-- no plugins, no fancy stuff, just the basics

-- {{{ convenience locals
local o = vim.opt
local optl = vim.opt_local
local g = vim.g
local au = vim.api.nvim_create_autocmd
-- }}}

-- sanitize workflow
g.mapleader = ','                      -- remap leader to ,
o.encoding = 'utf8'
o.wrap = false                         -- don't wrap lines
o.scrolloff = 8                        -- have some context around the current line always on screen
o.splitright = true                    -- split to the right by default
o.wildignore:append { '*.pyc', '*.o' } -- ignore some common extensions
o.updatetime = 50

-- set default <Tab> behavior: 4 spaces
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true

o.swapfile = false
o.backup = false
o.undodir = vim.fn.stdpath("state") .. "/undo"
o.undofile = true

-- searching behavior
o.hlsearch = true   -- highlight matches
o.incsearch = true  -- incremental search
o.ignorecase = true -- searches are case insensitive...
o.smartcase = true  -- ...unless they contain at least one capital letter
o.showmatch = true  -- show matching
-- <CR> to clear search highlight
vim.keymap.set('n', '<CR>', ':nohlsearch<CR>', { silent = true, desc = 'Clear search highlight' })
-- Restore <CR> behavior for quickfix and loclist
au('BufReadPost', {
    pattern = { 'quickfix', 'loclist' },
    callback = function()
        vim.keymap.set('n', '<CR>', '<CR>', { silent = true, buffer = true })
    end
})

-- dx strips trailing whitespace in normal mode
vim.cmd [[command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>]]
vim.keymap.set('n', 'dx', ':KillWhitespace<CR>', { silent = true, remap = true, desc = 'Remove trailing whitespace' })

g.no_plugin_maps = 1 -- disable plugin mappings
g.loaded_matchit = 1 -- disable matchit

-- {{{ common filetypes
vim.filetype.add({
    extension = {
        conf = 'conf',
        ejs = 'ejs',
    },
    filename = {
        ['.eslintrc'] = 'jsonc',
        ['.prettierrc'] = 'jsonc',
        ['.babelrc'] = 'jsonc',
        ['.stylelintrc'] = 'jsonc',
    },
    pattern = {
        ['.*config/git/config'] = 'gitconfig',
        ['.env.*'] = 'sh',
    },
})
-- }}}

-- {{{ UI setup and tweaks
o.cursorline = true            -- highlight the line of the cursor ...
o.cursorlineopt = { 'number' } -- ... but only when showing line numbers
o.textwidth = 120              -- 120 columns by default
o.colorcolumn = '0'            -- show vertical line after textwidth
o.number = true
o.relativenumber = true

o.foldcolumn = 'auto:9'
if vim.fn.has('nvim-0.9') == 1 then
    o.statuscolumn = ' %=%{v:relnum ? v:relnum : v:lnum} %s%C'
else
    o.signcolumn = 'number' -- always show the sign column
end
_G.heavy_border = { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' }
_G.textualize_border = { '🮇', '▔', '▎', '▎', '▎', '▁', '🮇', '🮇' }
_G.box_border = { '􀀁', '􀀄', '􀀂', '􀀆', '􀀃', '􀀅', '􀀀', '􀀇' }
_G.signs = { Error = '●', Warn = '▲', Hint = '■', Info = '◆', OK = '✔', Loading = '', LightBulb = '' }
_G.listchars = { tab = '▸ ', trail = '•', extends = '❯', precedes = '❮' }
_G.fillchars = {
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
}

o.lazyredraw = true    -- redraw only when we need to.
o.title = true         -- automatically set window title
o.termguicolors = true -- enable 24bit colors
o.fillchars:append(fillchars)
o.list = true
o.showbreak = '↪ '

-- Show listchars, except for tailing whitespace which is shown only on normal mode.
au('BufEnter', {
    callback = function()
        optl.listchars = vim.b.listchars or listchars
    end
})
au('InsertEnter', { callback = function() optl.listchars:remove('trail') end })
au('InsertLeave', { callback = function() optl.listchars:append({ trail = listchars.trail }) end })

vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
    group = vim.api.nvim_create_augroup("KittySetVarVimEnter", { clear = true }),
    callback = function()
        io.stdout:write("\x1b]1337;SetUserVar=in_editor=MQo\007")
    end,
})

vim.api.nvim_create_autocmd({ "VimLeave", "VimSuspend" }, {
    group = vim.api.nvim_create_augroup("KittyUnsetVarVimLeave", { clear = true }),
    callback = function()
        io.stdout:write("\x1b]1337;SetUserVar=in_editor\007")
    end,
})

-- Build diagnostic signs according to the signs table.
for kind, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. kind
    vim.fn.sign_define(hl, { text = icon, texthl = hl })
end
vim.fn.sign_define('LightBulbSign', { text = signs.LightBulb, texthl = 'LightBulbSign', numhl = 'LightBulbSign' })
-- }}}

-- {{{ spell checking because I'm terrible at spelling
local spellfile = vim.fn.stdpath('config') .. '/spell/techspeak.utf-8.add'
o.spell = true -- enable spell checking
o.spellfile = spellfile
o.spelloptions:append({ "camel" })
-- }}}
-- vim:foldmethod=marker:foldlevel=0
