require 'plugins'
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
-- }}}

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
vim.keymap.set('n', '<CR>', ':nohlsearch<CR>')
-- code editing
o.cursorline = true -- highlight the line of the cursor
o.textwidth = 120 -- 120 columns by default
o.colorcolumn = '+1' -- show vertical line after textwidth
o.signcolumn = 'yes' -- always show the sign column

-- UI setup and tweaks
local listchars = { tab = '▸ ', trail = '•', extends = '❯', precedes = '❮' }
-- local signs = { Error = '✖', Warn = ' ', Hint = '', Info = '',  OK='✔', Loading='', LightBulb = '' }
-- local signs = { Error = '•', Warn = '•', Hint = '•', Info = '•', OK='✔', Loading='', LightBulb = ''}
local signs = { Error = '●', Warn = '▲', Hint = '■', Info = '◆', OK = '✔', Loading = '', LightBulb = '' }

o.lazyredraw = true -- redraw only when we need to.
o.title = true -- automatically set window title
o.termguicolors = true -- enable 24bit colors
o.fillchars:append {
    eob = ' ', -- do not clutter empty space
    -- stl = '━',
    vert = '┃',
    horiz = '━',
    vertright = '┣',
    vertleft = '┫',
    verthoriz = '╋',
    horizup = '┻',
    horizdown = '┳',
}
local heavy_border = { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' }

-- {{{ indicator chars
o.list = true
o.showbreak = '↪ '

au('BufEnter', { callback = function()
    local _listchars = vim.b.listchars or listchars
    optl.listchars = _listchars
end })
au('InsertEnter', { callback = function() optl.listchars:remove('trail') end })
au('InsertLeave', { callback = function() optl.listchars:append({ trail = '•' }) end })
-- }}}
-- {{{ setup signs
for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
fn.sign_define('LightBulbSign', { text = signs.LightBulb, texthl = 'LightBulbSign', numhl = 'LightBulbSign' })
-- }}}

cmd.colorscheme 'selenized'

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

------------------------------------------------------------------------------------------------------------------------

-- {{{ trailing whitespace killer
vim.cmd [[command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>]]
vim.keymap.set('n', '<Leader>w', ':KillWhitespace<CR>')
-- }}}

local null_ls_sources = {}

-- {{{ LSP
local lspconfig = require('lspconfig')
local cmp = require('cmp')

local lspkind = require('lspkind')
local lsp_status = require('lsp-status')
-- local lsp_signature = require('lsp_signature')
local lightbulb = require('nvim-lightbulb')
local null_ls = require('null-ls')

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
    severity_sort = true,
})

vim.g.code_action_menu_window_border = heavy_border

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<Space>d', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<Space>q', vim.diagnostic.setloclist, opts)

-- lsp_signature.setup({
--     hint_enable = false,
--     bind = true, -- This is mandatory, otherwise border config won't get registered.
--     handler_opts = {
--         border = 'rounded'
--     }
-- })

lspconfig.defaults = {
    handlers = {
        ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = heavy_border }),
        ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = heavy_border }),
    },
    on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        -- goto
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

        -- under cursor
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', '<space>r', vim.lsp.buf.rename, bufopts)
        -- vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', '<space>ca', vim.cmd.CodeActionMenu, bufopts)

        -- global actions
        vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)

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

cmp.setup({
    preselect = cmp.PreselectMode.None,

    --  enabled = function()
    --      local context = require('cmp.config.context')
    --      return not(context.in_treesitter_capture('comment') == true or context.in_syntax_group('Comment'))
    --  end,

    experimental = {
        ghost_text = true,
    },
    -- view = {
    --     entries = 'native',
    -- },
    snippet = {
        expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

        ['<Esc>'] = cmp.mapping.abort(),
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
        ['<Left>'] = cmp.mapping.abort(),
        ['<Right>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item() -- be consistent with up/down
            elseif vim.fn['vsnip#available'](1) == 1 then
                feedkey('<Plug>(vsnip-expand-or-jump)', '')
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item() -- be consistent with up/down
            elseif vim.fn['vsnip#jumpable'](-1) == 1 then
                feedkey('<Plug>(vsnip-jump-prev)', '')
            else
                fallback()
            end
        end,
    }),
    sources = cmp.config.sources(
        {
            { name = 'cmp_git' },
        },
        {
            { name = 'vsnip' },
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

au('FileType', { pattern = { 'php.wp' }, callback = function()
    local _listchars = vim.deepcopy(listchars)
    _listchars['tab'] = '  '
    vim.b.listchars = _listchars
    vim.bo.expandtab = false
    vim.bo.copyindent = true
    vim.bo.preserveindent = true
    vim.bo.softtabstop = 0
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
end })

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

table.insert(null_ls_sources, null_ls.builtins.diagnostics.phpcs.with {
    prefer_local = 'vendor/bin',
})
table.insert(null_ls_sources, null_ls.builtins.formatting.phpcbf.with {
    prefer_local = 'vendor/bin',
})
-- }}}

-- {{{ go
au('FileType', { pattern = { 'go' }, callback = function()
    local _listchars = vim.deepcopy(listchars)
    _listchars['tab'] = '  '
    vim.b.listchars = _listchars
end })

lspconfig.gopls.setup(lspconfig.defaults)
table.insert(null_ls_sources, null_ls.builtins.diagnostics.golangci_lint.with {
    prefer_local = 'bin',
})
-- }}}

-- {{{ lua
lspconfig.sumneko_lua.setup(vim.tbl_extend('keep', lspconfig.defaults, {
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
        },
    },
}))

au('FileType', { pattern = { 'lua' }, callback = function()
    vim.b.surround_45 = '[[[ \\r ]]]'
    vim.b.surround_109 = '[[[ \\r ]]]'
end })
-- }}}

--{{{ Bash, shell, docker

lspconfig.bashls.setup(lspconfig.defaults)
table.insert(null_ls_sources, null_ls.builtins.diagnostics.shellcheck)

lspconfig.dockerls.setup(lspconfig.defaults)
table.insert(null_ls_sources, null_ls.builtins.diagnostics.hadolint)

--}}}

--{{{ EasyAlign
vim.keymap.set({ 'n', 'x' }, 'ga', '<Plug>(EasyAlign)')
--}}}

--{{{ autopairs
local autopairs = require('nvim-autopairs')
autopairs.setup({})
--}}}

-- {{{ null-ls
null_ls.setup({
    sources = null_ls_sources,
})
-- }}}
-- vim:foldmethod=marker:foldlevel=0
