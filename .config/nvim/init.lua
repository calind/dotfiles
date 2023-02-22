-- {{{ local definitions
local o = vim.opt
local g = vim.g
local optl = vim.opt_local
local cmd = vim.cmd
local fn = vim.fn
local stdpath = vim.fn.stdpath
local au = vim.api.nvim_create_autocmd
local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local map = function(mode, key, action, opts, desc)
    opts = opts or {}
    if type(opts) == 'string' then
        opts = { desc = opts }
    end
    opts.desc = desc or opts.desc
    vim.keymap.set(mode, key, action, opts)
end

local _map = function(mode, default_opts)
    default_opts = default_opts or {}
    return function(key, action, opts, desc)
        opts = opts or {}
        if type(opts) == 'string' then
            opts = { desc = opts }
        end
        opts = vim.tbl_extend('keep', default_opts, opts)
        map(mode, key, action, opts, desc)
    end
end

local nmap = _map('n', { silent = true })
local nnoremap = _map('n', { noremap = true, silent = true })

local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end
-- }}}

local snips_defaults = {
    ['author'] = 'Calin Don',
    ['author_url'] = 'https://calind.me',
    ['author_email'] = 'calin.don@gmail.com',
}
au('BufEnter', {
    callback = function()
        for k, v in pairs(snips_defaults) do
            vim.b['snips_' .. k] = vim.b['snips_' .. k] or v
        end
    end
})

au({'BufNewFile', 'BufRead'}, {
    callback = function ()
        local path = vim.fs.normalize(fn.expand('%:p'))
        vim.pretty_print(path)
        if path:find('github.com/bitpoke') then
            vim.b['snips_author'] = 'Bitpoke'
            vim.b['snips_author_url'] = 'https://bitpoke.io'
            vim.b['snips_author_email'] = 'hello@bitpoke.io'
        end
    end
})

-- sanitize workflow
g.mapleader = ',' -- remap leader to ,
o.encoding = 'utf8'
o.wrap = false -- don't wrap lines
o.scrolloff = 3 -- have some context around the current line always on screen
o.splitright = true -- split to the right by default
o.wildignore:append { '*.pyc', '*.o' } -- ignore some common extensions
o.updatetime = 300

-- set default <Tab> behavior: 4 spaces
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true

-- searching behavior
o.hlsearch = true -- highlight matches
o.incsearch = true -- incremental search
o.ignorecase = true -- searches are case insensitive...
o.smartcase = true -- ...unless they contain at least one capital letter
o.showmatch = true -- show matching
nmap('<CR>', ':nohlsearch<CR>', "Clear search highlight")

-- {{{ UI setup and tweaks
o.cursorline = true -- highlight the line of the cursor ...
o.cursorlineopt = { 'number' } -- ... but only when showing line numbers
o.textwidth = 120 -- 120 columns by default
o.colorcolumn = '0' -- show vertical line after textwidth
o.number = true
o.signcolumn = 'number' -- always show the sign column
o.foldcolumn = 'auto:9'
_G.heavy_border = { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' }
_G.signs = { Error = '●', Warn = '▲', Hint = '■', Info = '◆', OK = '✔', Loading = '', LightBulb = '' }
_G.listchars = { tab = '▸ ', trail = '•', extends = '❯', precedes = '❮' }
_G.fillchars = {
    eob = ' ', -- do not clutter empty space
    -- vert = '┃',
    -- horiz = '━',
    -- vertright = '┣',
    -- vertleft = '┫',
    -- verthoriz = '╋',
    -- horizup = '┻',
    -- horizdown = '┳',

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

o.lazyredraw = true -- redraw only when we need to.
o.title = true -- automatically set window title
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

-- Build diagnostic signs according to the signs table.
for kind, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. kind
    fn.sign_define(hl, { text = icon, texthl = hl })
end
fn.sign_define('LightBulbSign', { text = signs.LightBulb, texthl = 'LightBulbSign', numhl = 'LightBulbSign' })

-- Show colorcolumn only in insert mode
vim.cmd([[
augroup ColorColumnOnlyInInsertMode
  autocmd!
  autocmd InsertEnter * setlocal colorcolumn=+1
  autocmd InsertLeave * setlocal colorcolumn=0
augroup END
]])
-- }}}

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

-- {{{ spell checking because I'm terrible at spelling
local spellfile = stdpath('config') .. '/spell/techspeak.utf-8.add'
g.spellsync_run_at_startup = 1
o.spell = true -- enable spell checking
o.spellfile = spellfile
-- }}}

-- {{{ trailing whitespace killer
vim.cmd [[command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>]]
nmap('dx', ':KillWhitespace<CR>', 'Remove trailing whitespace')
-- }}}

-- {{{ load impatient
local ok, impatient = pcall(require, 'impatient')
if ok then
    impatient.enable_profile()
end
-- }}}

cmd.colorscheme 'selenized'

require 'plugins'

local null_ls_sources = {}

-- {{{ which-key
local wk = require("which-key")

o.timeoutlen = 150
wk.setup({
    plugins = {
        spelling = {
            enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 10, -- how many suggestions should be shown in the list?
        },
    },
    operators = {
        ["]x"] = "XML encode",
        ["[x"] = "XML decode",
        ["]u"] = "URL encode",
        ["[u"] = "URL decode",
        ["]y"] = "C string encode",
        ["[y"] = "C string decode",
        ["]C"] = "C string encode",
        ["[C"] = "C string decode",
        ["ga"] = "Align",
        -- ["gc"] = "Comment",
        ["gq"] = "Format",
        ["gw"] = "Text format",
    },
    window = {
        border = heavy_border,
        margin = { 1, 10, 1, 10 },
        padding = { 1, 0, 1, 0 },
    }
})
wk.register({
    gq = { name = "Format" },
    gqq = "Format current line",
    gw = { name = "Text format" },
    gww = "Text format current line",
}, {
    mode = { 'n', 'v' }
})
-- }}}

-- {{{ vim-surround
wk.register({
    cs = "Change surrounds",
    cS = "Change surrounds \n",
    ds = "Delete surrounds",
    ys = "Insert surrounds",
    yS = "Insert surrounds (\n)",
    yss = "Insert surrounds (l)",
    ySs = "Insert surrounds (l/\n)",
    ySS = "Insert surrounds (l/\n)",
}, {
    mode = "n",
    noremap = true,
})
wk.register({
    gS = "Insert surrounds \n",
}, {
    mode = "v",
    noremap = true,
})
-- }}}

-- {{{ vim-commentary

wk.register({ gc = { name = "Comment" } }, { mode = { 'n' } })
wk.register({ gc = "Comment" }, { mode = { 'v' } })
wk.register({ gcc = "Comment toggle for current line" })

-- }}}

-- {{{ vim-unimpaired
wk.register({
    yo = "Toggle option",
})

local unimpaired_toggles = {
    b = 'background light',
    c = 'cursorline',
    d = 'diff',
    h = 'hlsearch',
    i = 'ignorecase',
    l = 'list',
    n = 'number',
    r = 'relativenumber',
    s = 'spell',
    t = 'colorcolumn',
    u = 'cursorcolumn',
    v = 'virtualedit',
    w = 'wrap',
    x = 'cursorline x cursorcolumn',
}

wk.register({ ['yo'] = { name = "Toggle option", unimpaired_toggles } })
wk.register({ ['=s'] = { name = "Toggle option", unimpaired_toggles } })
wk.register({ [']o'] = { name = "Disable option", unimpaired_toggles } })
wk.register({ ['>o'] = { name = "Disable option", unimpaired_toggles } })
wk.register({ ['[o'] = { name = "Enable option", unimpaired_toggles } })
wk.register({ ['<o'] = { name = "Enable option", unimpaired_toggles } })

wk.register({
    a = 'Edit next file (:next)',
    A = 'Edit first file (:first)',
    b = 'Next buffer (:bnext)',
    B = 'Last buffer (:blast)',
    l = 'Loclist next (:lnext)',
    L = 'Loclist last (:llast)',
    ['<C-L>'] = 'First error in next loclist file (:lnfile)',
    q = 'Quickfix next (:cnext)',
    Q = 'Quickfix last (:clast)',
    ['<C-Q>'] = 'First error in next quickfix file (:cnfile)',
    t = 'Next tag (:tnext)',
    T = 'Last tag (:tlast)',
    ['<C-T>'] = 'Next tag in preview window (:ptnext)',
    f = 'Next file in current directory',
    n = 'Next SCM conflict',
    ['<space>'] = 'Insert blank line below cursor',
    e = 'Exchange with next line',
    x = 'XML decode',
    xx = 'XML decode',
    u = 'URL decode',
    uu = 'URL decode',
    y = 'C string decode',
    yy = 'C string decode',
    C = 'C string decode',
    CC = 'C string decode',
    p = 'Paste after current line',
    P = 'Paste after current line',
}, {
    prefix = ']'
})

wk.register({
    p = 'Paste after current line',
    P = 'Paste before current line',
}, {
    prefix = '>'
})

wk.register({
    a = 'Edit previous file (:previous)',
    A = 'Edit last file (:last)',
    b = 'Previous buffer (:bprevious)',
    B = 'Last buffer (:blast)',
    l = 'Loclist previous (:lprevious)',
    L = 'Loclist last (:llast)',
    ['<C-L>'] = 'last error in previous loclist file (:lpfile)',
    q = 'Quickfix previous (:cprevious)',
    Q = 'Quickfix last (:clast)',
    ['<C-Q>'] = 'last error in previous quickfix file (:cpfile)',
    t = 'Previous tag (:tprevious)',
    T = 'Last tag (:tlast)',
    ['<C-T>'] = 'Previous tag in preview window (:ptprevious)',
    f = 'Previous file in current directory',
    n = 'Previous SCM conflict',
    ['<space>'] = 'Insert blank line above cursor',
    e = 'Exchange with previous line',
    x = 'XML encode',
    xx = 'XML encode',
    u = 'URL encode',
    uu = 'URL encode',
    y = 'C String encode',
    yy = 'C String encode',
    C = 'C String encode',
    CC = 'C String encode',
    p = 'Paste before current line',
    P = 'Paste before current line',
}, {
    prefix = '['
})

wk.register({
    p = 'Paste after current line',
    P = 'Paste before current line',
}, {
    prefix = '<'
})

wk.register({
    p = 'Paste after current line, reindenting',
    P = 'Paste before current line, reindenting',
}, {
    prefix = '='
})
-- }}}

--{{{ vsnip
-- vim.g.vsnip_snippet_dir = vim.fn.stdpath('config') .. '/snippets'

-- fn["vsnip#variable#register"]('VSNIP_DASHCASE_FILENAME', function(_)
--     return textcase.to_dash_case(fn.expand('%:p:t:r'))
-- end)
-- fn["vsnip#variable#register"]('VSNIP_SNAKECASE_FILENAME', function(_)
--     return textcase.to_snake_case(fn.expand('%:p:t:r'))
-- end)
-- fn["vsnip#variable#register"]('VSNIP_TITLECASE_FILENAME', function(_)
--     return textcase.to_title_case(fn.expand('%:p:t:r'))
-- end)
-- fn["vsnip#variable#register"]('VSNIP_DASH_TITLECASE_FILENAME', function(_)
--     return textcase.to_title_case(fn.expand('%:p:t:r')):gsub(' ', '_')
-- end)
-- fn["vsnip#variable#register"]('VSNIP_CAMELCASE_FILENAME', function(_)
--     return textcase.to_camel_case(fn.expand('%:p:t:r'))
-- end)
-- fn["vsnip#variable#register"]('VSNIP_PASCALCASE_FILENAME', function(_)
--     return textcase.to_pascal_case(fn.expand('%:p:t:r'))
-- end)

-- fn["vsnip#variable#register"]('TM_AUTHOR', function(_)
--     return vim.b['snips_author'] or 'Please, set b:snips_author'
-- end)
-- fn["vsnip#variable#register"]('TM_AUTHOR_URL', function(_)
--     return vim.b['snips_author_url'] or 'Please, set b:snips_author_url'
-- end)
-- fn["vsnip#variable#register"]('TM_AUTHOR_EMAIL', function(_)
--     return vim.b['snips_author_email'] or 'Please, set b:snips_author_email'
-- end)
--}}}

-- {{{ LSP
local lspconfig = require('lspconfig')
local cmp = require('cmp')

local lspkind = require('lspkind')
local lsp_status = require('lsp-status')
-- local lsp_signature = require('lsp_signature')
local lightbulb = require('nvim-lightbulb')
local null_ls = require('null-ls')

local root_pattern = require("null-ls.utils").root_pattern

require('lspconfig.ui.windows').default_options.border = heavy_border
lsp_status.register_progress()
lsp_status.config({
    kind_labels = lspkind.presets.default,
    spinner_frames = { signs.Loading },
    indicator_ok = signs.OK,
    indicator_errors = signs.Error,
    indicator_warnings = signs.Warn,
    indicator_info = signs.Info,
    indicator_hint = signs.Hint,
})
lightbulb.setup({
    sign = { enabled = false },
    status_text = { enabled = true, text = signs.LightBulb },
    autocmd = {
        enabled = true
    }
})


vim.diagnostic.config({
    float = {
        border = heavy_border,
    },
    virtual_text = {
        source = 'if_many',
    },
    signs = {
        priority = 50,
    },
    severity_sort = true,
})

vim.g.code_action_menu_window_border = heavy_border


-- lsp_signature.setup({
--     hint_enable = false,
--     bind = true, -- This is mandatory, otherwise border config won't get registered.
--     handler_opts = {
--         border = 'rounded'
--     }
-- })

wk.register({ ["<space>"] = { name = "LSP" } })

local lsp_formatters = {}

lspconfig.defaults = {
    handlers = {
        ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = heavy_border }),
        ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = heavy_border }),
    },
    on_attach = function(client, bufnr)
        ---@diagnostic disable-next-line: redefined-local
        local format_filter = function(client)
            local ft = vim.bo[bufnr].filetype
            local formatters = vim.b[bufnr].lsp_formatters or lsp_formatters[ft] or {}
            if vim.tbl_isempty(formatters) or vim.tbl_contains(formatters, client.name) then
                return true
            end
            return false
        end

        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap = true, silent = true, buffer = bufnr }

        -- diagnostics
        nmap('[d', vim.diagnostic.goto_prev, bufopts, 'Go to previous diagnostic')
        nmap(']d', vim.diagnostic.goto_next, bufopts, 'Go to next diagnostic')
        nmap('<Space>d', vim.diagnostic.open_float, bufopts, 'Preview diagnostic')
        nmap('<Space>q', vim.diagnostic.setloclist, bufopts, 'Open loclist')

        -- goto
        nmap('gd', vim.lsp.buf.definition, bufopts, 'Go to definition')
        nmap('gD', vim.lsp.buf.declaration, bufopts, 'Go to declaration')
        nmap('gi', vim.lsp.buf.implementation, bufopts, 'Show implementations')
        nmap('gr', vim.lsp.buf.references, bufopts, 'Show references ')
        nmap('gT', vim.lsp.buf.type_definition, bufopts, 'Go to type definition')

        -- under cursor
        nmap('K', vim.lsp.buf.hover, bufopts)
        nmap('<C-k>', vim.lsp.buf.signature_help, bufopts)
        nmap('<space>r', vim.lsp.buf.rename, bufopts, 'Rename')
        -- nmap('<space>ca', vim.lsp.buf.code_action, bufopts)
        nmap('<space>c', vim.cmd.CodeActionMenu, bufopts, 'Code Action')

        -- global actions
        nmap('<space>f', function() vim.lsp.buf.format { async = true, filter = format_filter } end, bufopts, 'Format')

        -- LSP workspace
        wk.register({ ['<space>w'] = { name = "Workspace" }, { buffer = bufnr } })
        nmap('<space>wa', vim.lsp.buf.add_workspace_folder, bufopts, 'Add workspace folder')
        nmap('<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts, 'Remove workspace folder')
        nmap('<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts, 'List workspace folders')

        lsp_status.on_attach(client)
        -- lsp_signature.on_attach(nil, bufnr)
    end,
    capabilities = vim.tbl_extend('keep', require('cmp_nvim_lsp').default_capabilities(),
        lsp_status.capabilities
    ),
    flags = {
        debounce_text_changes = 150,
    },
}

o.completeopt = 'menuone,noselect,preview'

require("copilot").setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
})

require("copilot_cmp").setup({})
local snippy = require('snippy')
local cmp_insert_mapping = {
    ['<C-b>'] = cmp.mapping.scroll_docs( -4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<Esc>'] = cmp.mapping(function(fallback)
        if snippy.is_active() then
            require('snippy.buf').clear_state()
        end
        cmp.abort()
        fallback()
    end, { 'i', 's' }),
    ['<Esc><Esc>'] = cmp.mapping(function()
        cmp.mapping.abort()
        vim.cmd.stopinsert()
    end),
    ['<Esc>:'] = cmp.mapping(function()
        cmp.mapping.abort()
        vim.cmd.stopinsert()
        feedkey(':', 'n')
    end),
    ['<Esc>/'] = cmp.mapping(function()
        cmp.mapping.abort()
        vim.cmd.stopinsert()
        feedkey('/', 'n')
    end),
    ['<Esc>?'] = cmp.mapping(function()
        cmp.mapping.abort()
        vim.cmd.stopinsert()
        feedkey('?', 'n')
    end),
    ['<Left>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.abort()
        end
        -- if vim.fn['vsnip#jumpable']( -1) == 1 then
        --     feedkey('<Plug>(vsnip-jump-prev)', '')
        if snippy.can_jump( -1) then
            snippy.previous()
        else
            fallback()
        end
    end, { 'i', 's' }),
    ['<Right>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.abort()
        end
        -- if vim.fn['vsnip#available'](1) == 1 then
        --     feedkey('<Plug>(vsnip-expand-or-jump)', '')
        if snippy.can_expand_or_advance() then
            snippy.expand_or_advance()
        else
            fallback()
        end
    end, { 'i', 's' }),
    ['<CR>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace }) -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            if cmp.get_active_entry() then
                -- elseif vim.fn['vsnip#available'](1) == 1 then
                --     feedkey('<Plug>(vsnip-expand-or-jump)', '')
                if snippy.can_expand_or_advance() then
                    snippy.expand_or_advance()
                end
            else
                fallback()
            end
        else
            fallback()
        end
    end, { 'i', 's' }),
    ['<Down>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select }) -- be consistent with up/down
        else
            fallback()
        end
    end, { 'i', 's' }),
    ['<Tab>'] = cmp.mapping(function(fallback)
        -- if vim.fn['vsnip#available'](1) == 1 then
        --     feedkey('<Plug>(vsnip-expand-or-jump)', '')
        if snippy.can_expand_or_advance() then
            snippy.expand_or_advance()
        elseif cmp.visible() and has_words_before() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select }) -- be consistent with up/down
        else
            fallback()
        end
    end, { 'i', 's' }),
    ['<Up>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select }) -- be consistent with up/down
        else
            fallback()
        end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
        if snippy.can_jump( -1) then
            snippy.previous()
            -- if vim.fn['vsnip#jumpable']( -1) == 1 then
            --     feedkey('<Plug>(vsnip-jump-prev)', '')
        elseif cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select }) -- be consistent with up/down
        else
            fallback()
        end
    end, { 'i', 's' }),
}

cmp.setup({
    preselect = cmp.PreselectMode.None,
    --  enabled = function()
    --      local context = require('cmp.config.context')
    --      return not(context.in_treesitter_capture('comment') == true or context.in_syntax_group('Comment'))
    --  end,

    experimental = {
        ghost_text = { hl_group = 'Suggestion' },
    },
    -- view = {
    --     entries = 'native',
    -- },
    snippet = {
        expand = function(args)
            snippy.expand_snippet(args.body) --            vim.fn['vsnip#anonymous'](args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert(cmp_insert_mapping),
    sources = cmp.config.sources(
        {
            { name = 'cmp_git' },
        },
        {
            { name = 'copilot' },
            { name = 'snippy' },
            { name = 'nvim_lsp' },
        },
        {
            { name = 'path' },
            { name = 'calc' },
        },
        {
            { name = 'buffer' },
        }
    ),
    -- Pictograms
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol_text',
            symbol_map = { Copilot = "" },
            maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
        })
    },
    window = {
        documentation = {
            border = heavy_border,
            winhighlight = '',
        },
        completion = {
            border = heavy_border,
            winhighlight = '',
        },
    },
})

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done()
)


-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources(
        {
            { name = 'nvim_lsp_document_symbol' }
        },
        {
            { name = 'buffer' }
        }
    )
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})
-- }}}

-- {{{ git
require("cmp_git").setup({
    -- defaults
    filetypes = { "gitcommit" },
    github = {
        issues = {
            filter = "all", -- assigned, created, mentioned, subscribed, all, repos
            limit = 100,
            state = "open", -- open, closed, all
        },
        mentions = {
            limit = 100,
        },
    },
    gitlab = {
        issues = {
            limit = 100,
            state = "opened", -- opened, closed, all
        },
        mentions = {
            limit = 100,
        },
        merge_requests = {
            limit = 100,
            state = "opened", -- opened, closed, locked, merged
        },
    },
})

local gitsigns = require('gitsigns')
gitsigns.setup({
    signs = {
        add          = { text = '┃', },
        change       = { text = '┃', },
        delete       = { text = '┃', },
        topdelete    = { text = '┃', },
        changedelete = { text = '┃', },
    },
    sign_priority = 1,
    attach_to_untracked = false,
    preview_config = {
        -- Options passed to nvim_open_win
        border = heavy_border,
    },
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
})

wk.register({ ['=h'] = { name = "git hunk" } }, { mode = { 'n', 'v' } })

-- Navigation
map('n', ']c', function()
    if vim.wo.diff then return ']c' end
    vim.schedule(function() gitsigns.next_hunk() end)
    return '<Ignore>'
end, { expr = true }, 'Next change')

map('n', '[c', function()
    if vim.wo.diff then return '[c' end
    vim.schedule(function() gitsigns.prev_hunk() end)
    return '<Ignore>'
end, { expr = true }, 'Previous change')

-- Actions
map({ 'n', 'v' }, '=hs', ':Gitsigns stage_hunk<CR>', 'Stage hunk')
map({ 'n', 'v' }, '=hr', ':Gitsigns reset_hunk<CR>', 'Reset hunk')
map('n', '=hu', gitsigns.undo_stage_hunk, 'Undo staged hunk')
map('n', '=hS', gitsigns.stage_buffer, 'Stage buffer')
map('n', '=hR', gitsigns.reset_buffer, 'Reset buffer')
map('n', '=hh', gitsigns.preview_hunk, 'Preview hunk')
map('n', '=hb', function() gitsigns.blame_line { full = true } end, 'Show git blame')
map('n', '=hd', gitsigns.diffthis, 'Diff from index')
map('n', '=hD', function() gitsigns.diffthis('~') end, 'Diff from HEAD~')

map('n', 'yoD', gitsigns.toggle_deleted, "git deleted")
map('n', '=sD', gitsigns.toggle_deleted, "git deleted")
map('n', '=sB', gitsigns.toggle_current_line_blame, "git blame")
map('n', 'yoB', gitsigns.toggle_current_line_blame, "git blame")

-- Text object
map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'hunk')
-- }}}

-- {{{ lualine config
local lualine = require('lualine')
lualine.setup {
    options = {
        section_separators = '',
        component_separators = '❙',
        globalstatus = true,
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = {
            {
                function() return lightbulb.get_status_text() end,
                separator = '',
                padding = { left = 1, right = 0 },
            },
            {
                'filename',
                file_status = true, -- Displays file status (readonly status, modified status)
                newfile_status = true, -- Display new file status (new file means no write after created)
                symbols = {
                    readonly = '[]',
                },
            },
        },
        lualine_c = {
            'searchcount',
            function() return fn['nvim_treesitter#statusline']() end
        },
        lualine_x = {
            {
                function() return lsp_status.status_progress() end
            },
            {
                'diagnostics',
                sources = { 'nvim_lsp' },
                -- always_visible = true,
                -- color = function(section) return { bg = colors.bg_2 } end
            },
            {
                function() return vim.b.gitsigns_status or '' end
            },
            {
                'fileformat',
                symbols = {
                    unix = 'unix',
                    dos = 'dos',
                    mac = 'mac',
                }
            },
            'encoding',
            'filetype',
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
}
-- }}}

--{{{ ltex

lspconfig.ltex.setup(lspconfig.defaults)
-- local ltex_language_id_mapping = {
--   bib = 'bibtex',
--   plaintex = 'tex',
--   rnoweb = 'sweave',
--   rst = 'restructuredtext',
--   tex = 'latex',
--   xhtml = 'xhtml',
--   ['php.wp'] = 'php',
--   shell = 'shellscript',
-- }
--
-- lspconfig.ltex.setup(vim.tbl_extend('keep', lspconfig.defaults, {
--     filetypes = {
--         'bib', 'gitcommit', 'markdown', 'org', 'plaintex', 'rst', 'rnoweb', 'tex',
--         -- enable LTeX for programming languages
--         'go', 'php', 'php.wp', 'shell', 'python', 'sql', 'lua',
--         'javascript', 'javascriptreact', 'typescript', 'typescriptreact'
--    },
--     get_language_id = function(_, filetype)
--         local language_id = ltex_language_id_mapping[filetype]
--         if language_id then
--             return language_id
--         else
--             return filetype
--         end
--     end,
--     settings = {
--         ltex = {
--             enabled = {
--                 'bibtex', 'context', 'context.tex', 'html', 'latex', 'markdown', 'org', 'restructuredtext', 'rsweave',
--                 'shellscript', 'php', 'go', 'lua', 'python', 'sql',
--                 'javascript', 'javascriptreact', 'typescript', 'typescriptreact'}
--         },
--     },
-- }))
--}}}

--{{{ html/css/json
lspconfig.html.setup(lspconfig.defaults)
lspconfig.cssls.setup(lspconfig.defaults)
lspconfig.jsonls.setup(lspconfig.defaults)
--}}}

-- {{{ php
vim.filetype.add({
    extension = {
        phpt = 'php',
    },
    filename = {
        ['object-cache.php'] = 'php.wp',
        ['advanced-cache.php'] = 'php.wp',
    },
    pattern = {
        ['.*/wp%-includes/*.php'] = 'php.wp',
        ['.*/wp%-admin/*.php'] = 'php.wp',
        ['.*/wp%-content/*.php'] = 'php.wp',
        ['.*/wp%-.*.php'] = 'php.wp',
        ['.*/class%-.*.php'] = 'php.wp',
        ['.*/interface%-.*.php'] = 'php.wp',
    },
})

au('FileType', {
    pattern = { 'php.wp' },
    callback = function()
        local _listchars = vim.deepcopy(listchars)
        _listchars['tab'] = '  '
        vim.b.listchars = _listchars
        vim.bo.expandtab = false
        vim.bo.copyindent = true
        vim.bo.preserveindent = true
        vim.bo.softtabstop = 0
        vim.bo.shiftwidth = 4
        vim.bo.tabstop = 4
    end
})

local intelephense_default_stubs = {
    'apache', 'bcmath', 'bz2', 'calendar', 'com_dotnet', 'Core', 'ctype', 'curl', 'date', 'dba', 'dom', 'enchant',
    'exif', 'FFI', 'fileinfo', 'filter', 'fpm', 'ftp', 'gd', 'gettext', 'gmp', 'hash', 'iconv', 'imap', 'intl', 'json',
    'ldap', 'libxml', 'mbstring', 'meta', 'mysqli', 'oci8', 'odbc', 'openssl', 'pcntl', 'pcre', 'PDO', 'pdo_ibm',
    'pdo_mysql', 'pdo_pgsql', 'pdo_sqlite', 'pgsql', 'Phar', 'posix', 'pspell', 'readline', 'Reflection', 'session',
    'shmop', 'SimpleXML', 'snmp', 'soap', 'sockets', 'sodium', 'SPL', 'sqlite3', 'standard', 'superglobals', 'sysvmsg',
    'sysvsem', 'sysvshm', 'tidy', 'tokenizer', 'xml', 'xmlreader', 'xmlrpc', 'xmlwriter', 'xsl', 'Zend OPcache', 'zip',
    'zlib'
}

table.insert(intelephense_default_stubs, 'wordpress')
table.insert(intelephense_default_stubs, 'memcache')
table.insert(intelephense_default_stubs, 'memcached')

lspconfig.intelephense.setup(vim.tbl_extend('keep', lspconfig.defaults, {
    get_language_id = function() return 'php' end,
    filetypes = { 'php', 'php.wp' },
    settings = {
        intelephense = {
            stubs = intelephense_default_stubs,
            files = {
                maxSize = 5000000,
            }
        }
    }
}))

lsp_formatters['php'] = { 'null-ls' }
lsp_formatters['php.wp'] = lsp_formatters['php']

table.insert(null_ls_sources, null_ls.builtins.diagnostics.phpcs.with {
    prefer_local = 'vendor/bin',
    -- use WordPress coding standards for files detected as php.wp
    extra_args = function(params)
        if params.ft == "php.wp" then
            -- skip for code under custom phpcs config file
            local local_root = root_pattern("phpcs.xml.dist", "phpcs.xml")(params.bufname)
            return not local_root and { '--standard=WordPress' }
        end
    end,
    cwd = function(params)
        local local_root = root_pattern("phpcs.xml.dist", "phpcs.xml")(params.bufname)
        return local_root or params.root
    end,
})
table.insert(null_ls_sources, null_ls.builtins.formatting.phpcbf.with {
    prefer_local = 'vendor/bin',
    -- use WordPress coding standards for files detected as php.wp
    extra_args = function(params)
        if params.ft == "php.wp" then
            -- skip for code under custom phpcs config file
            local local_root = root_pattern("phpcs.xml.dist", "phpcs.xml")(params.bufname)
            return not local_root and { '--standard=WordPress' }
        end
    end,
    cwd = function(params)
        local local_root = root_pattern("phpcs.xml.dist", "phpcs.xml")(params.bufname)
        return local_root or params.root
    end,
})
-- }}}

-- {{{ go
au('FileType', {
    pattern = { 'go' },
    callback = function()
        local _listchars = vim.deepcopy(listchars)
        _listchars['tab'] = '  '
        vim.b.listchars = _listchars
    end
})

lspconfig.gopls.setup(lspconfig.defaults)
table.insert(null_ls_sources, null_ls.builtins.diagnostics.golangci_lint.with {
    prefer_local = 'bin',
})
-- }}}

-- {{{ lua
lspconfig.lua_ls.setup(vim.tbl_extend('keep', lspconfig.defaults, {
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
        },
    },
}))

au('FileType', {
    pattern = { 'lua' },
    callback = function()
        vim.b.surround_45 = '[[[ \\r ]]]'
        vim.b.surround_109 = '[[[ \\r ]]]'
    end
})
-- }}}

--{{{ Bash, shell, docker

lspconfig.bashls.setup(lspconfig.defaults)
table.insert(null_ls_sources, null_ls.builtins.diagnostics.shellcheck)

lspconfig.dockerls.setup(lspconfig.defaults)
table.insert(null_ls_sources, null_ls.builtins.diagnostics.hadolint)

--}}}

--{{{ EasyAlign
map({ 'n', 'x' }, 'ga', '<Plug>(EasyAlign)')
wk.register({
    ga = {
        name        = "Align",

        ['<Space>'] = 'General alignment around whitespaces',
        ['=']       = 'Operators containing equals sign ( `=` ,  `==,`  `!=` ,  `+=` ,  `&&=` , ...)',
        [':']       = 'Suitable for formatting JSON or YAML',
        ['.']       = 'Multi-line method chaining',
        [',']       = 'Multi-line method arguments',
        ['&']       = 'LaTeX tables (matches  `&`  and  `\\` )',
        ['#']       = 'Ruby/Python comments',
        ['"']       = 'Vim comments',
        ['<Bar>']   = 'Table markdown',
    }
}, {
    mode = { 'n', 'v' }
})
--}}}

--{{{ nvim-autopairs
local npairs = require('nvim-autopairs')
npairs.Rule = require('nvim-autopairs.rule')
npairs.cond = require'nvim-autopairs.conds'
npairs.setup({
    enable_check_bracket_line = true,
})

-- Add spaces between parentheses
local brackets = { { '(', ')' }, { '[', ']' }, { '{', '}' } }
npairs.add_rules {
  npairs.Rule(' ', ' ')
    :with_pair(function(opts)
      local pair = opts.line:sub(opts.col -1, opts.col)
      return vim.tbl_contains({
        brackets[1][1]..brackets[1][2],
        brackets[2][1]..brackets[2][2],
        brackets[3][1]..brackets[3][2]
      }, pair)
    end)
    :with_move(npairs.cond.none())
    :with_cr(npairs.cond.none())
    :with_del(function(opts)
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local context = opts.line:sub(col - 1, col + 2)
      return vim.tbl_contains({
        brackets[1][1]..'  '..brackets[1][2],
        brackets[2][1]..'  '..brackets[2][2],
        brackets[3][1]..'  '..brackets[3][2]
      }, context)
    end)
}
for _,bracket in pairs(brackets) do
  npairs.Rule('', ' '..bracket[2])
    :with_pair(npairs.cond.none())
    :with_move(function(opts) return opts.char == bracket[2] end)
    :with_cr(npairs.cond.none())
    :with_del(npairs.cond.none())
    :use_key(bracket[2])
end
--}}}

--{{{ treesitter
require('nvim-treesitter.configs').setup {
    -- A list of parser names, or 'all'
    ensure_installed = {
        'go', 'gomod',
        'php',
        'python',
        'lua',
        'c', 'cpp', 'c_sharp',
        'javascript', 'typescript', 'tsx', 'jq',
        'html', 'css',
        'sql',
        'vim', 'help',
        'markdown', 'comment', 'dot',
        'bash', 'dockerfile', 'make', 'diff', 'awk',
        'git_rebase', 'gitignore', 'gitattributes', 'gitcommit',
        'json', 'jsonc', 'yaml', 'toml', 'hcl', 'jsonnet',
        'proto',
    },

    ignore_install = {
        "phpdoc", -- wait until claytonrcarter/tree-sitter-phpdoc#1 is completed
    },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    highlight = {
        -- `false` will disable the whole extension
        enable = true,

        -- disable slow treesitter highlight for large files
        disable = function(_, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
}

nnoremap('<leader>t', cmd.TSHighlightCapturesUnderCursor, 'Show highlight captures')

--}}}

-- {{{ null-ls
null_ls.setup({
    debug = true,
    sources = null_ls_sources,
    border = heavy_border,
})
-- }}}
-- vim:foldmethod=marker:foldlevel=0
