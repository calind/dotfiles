-- {{{ local definitionsp
local o = vim.opt
local g = vim.g
local optl = vim.opt_local
local cmd = vim.cmd
local fn = vim.fn
local stdpath = vim.fn.stdpath
local au = vim.api.nvim_create_autocmd
local ag = vim.api.nvim_create_augroup
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
    if vim.bo.buftype == "prompt" then return false end
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

au({ 'BufNewFile', 'BufRead' }, {
    callback = function()
        local path = vim.fs.normalize(fn.expand('%:p'))
        if path:find('github.com/bitpoke') then
            vim.b['snips_author'] = 'Bitpoke'
            vim.b['snips_author_url'] = 'https://bitpoke.io'
            vim.b['snips_author_email'] = 'hello@bitpoke.io'
        end
    end
})

-- minimal, sans-plugins, config
vim.loader.enable()
require 'minimal'
require 'plugins'

-- vim.keymap.set("c", "wq", function()
--     print("Use :w then :q to save and quit")
-- end, { noremap = true, silent = true })
-- vim.cmd([[
-- cnoreabbrev <expr> x getcmdtype() == ":" && getcmdline() == 'x' ? 'w<bar>bd' : 'x'
-- cnoreabbrev <expr> wq getcmdtype() == ":" && getcmdline() == 'wq' ? 'w<bar>bd' : 'wq'
-- cnoreabbrev <expr> q getcmdtype() == ":" && getcmdline() == 'q' ? 'bd' : 'q'
-- ]])

_G.default_border = box_border
require 'hl-codeblock'

local null_ls_sources = {}

local otter = require('otter')
otter.setup({
    lsp = {
        border = default_border,
    },
    buffers = {
        set_filetype = true,
    },
})
au('FileType', {
    pattern = { 'html', 'htmldjango', 'php', 'php.wp' },
    callback = function(args)
        local buf = args.buf
        otter.activate({ 'javascript' })
        vim.api.nvim_buf_create_user_command(buf, 'OtterRename', otter.ask_rename, {})
        vim.api.nvim_buf_create_user_command(buf, 'OtterHover', otter.ask_hover, {})
        vim.api.nvim_buf_create_user_command(buf, 'OtterReferences', otter.ask_references, {})
        vim.api.nvim_buf_create_user_command(buf, 'OtterTypeDefinition', otter.ask_type_definition, {})
        vim.api.nvim_buf_create_user_command(buf, 'OtterDefinition', otter.ask_definition, {})
        vim.api.nvim_buf_create_user_command(buf, 'OtterFormat', otter.ask_format, {})
        vim.api.nvim_buf_create_user_command(buf, 'OtterDocumentSymbols', otter.ask_document_symbols, {})
    end
})

nmap('<ESC>', function()
    vim.cmd('cclose')
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= "" then
            vim.api.nvim_win_close(win, false)
        end
    end
end)

nmap('<D-]>', vim.cmd.tabnext, 'Next ,tab')
nmap('<D-[>', vim.cmd.tabprevious, 'Previous tab')
map({ 'n', 'i' }, '<D-f>', function()
    local mode = vim.api.nvim_get_mode().mode

    if mode == 'n' then
        feedkey('/', 'n')
    elseif mode == 'i' then
        feedkey('<Esc>/', 'n')
    end
end, 'Search')

vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous" })

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over without yanking" })

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank to clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete into the void" })

-- the differences are so subtle that it's hard to tell them apart
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>t", ":Inspect<CR>", { desc = "Inspect" })
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undo tree" })

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
-- {{{ which-key
local wk = require("which-key")

o.timeoutlen = 150
wk.setup({
    plugins = {
        spelling = {
            enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
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
        border = default_border,
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

--{{{ mason (this MUST be set up before LSP and null-ls)
require("mason").setup({
    ui = {
        border = default_border,
    }
})
require("mason-lspconfig").setup({ automatic_installation = true })
require("mason-null-ls").setup({ automatic_installation = { exclude = { "phpcs", "phpcbf" } } })
--}}}

-- {{{ LSP
local lspconfig = require('lspconfig')
local cmp = require('cmp')

local lspkind = require('lspkind')
local lsp_status = require('lsp-status')
-- local lsp_signature = require('lsp_signature')
local lightbulb = require('nvim-lightbulb')
local null_ls = require('null-ls')

local null_ls_root_pattern = require("null-ls.utils").root_pattern

require('lspconfig.ui.windows').default_options.border = default_border
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
        border = default_border,
    },
    virtual_text = {
        source = 'if_many',
    },
    signs = {
        priority = 50,
    },
    severity_sort = true,
})

vim.g.code_action_menu_window_border = default_border


-- lsp_signature.setup({
--     hint_enable = false,
--     bind = true, -- This is mandatory, otherwise border config won't get registered.
--     handler_opts = {
--         border = 'rounded'
--     }
-- })

wk.register({ ["<space>"] = { name = "LSP" } })

local lsp_formatters = {}
local format_filter = function(client)
    local ft = vim.bo.filetype
    local formatters = vim.b.lsp_formatters or lsp_formatters[ft] or {}
    if vim.tbl_isempty(formatters) or vim.tbl_contains(formatters, client.name) then
        return true
    end
    return false
end

local format = function(args)
    local active_clients = vim.lsp.get_active_clients({ name = 'tailwindcss' })
    -- if active_clients and #active_clients > 0 then
    --     require('tailwind-tools.lsp').sort_classes()
    -- end
    vim.lsp.buf.format({ async = false, filter = format_filter })
end

lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config,
    {
        handlers = {
            ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = default_border }),
            ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = default_border }),
        },
        capabilities = vim.tbl_extend('keep', require('cmp_nvim_lsp').default_capabilities(),
            lsp_status.capabilities,
            {
                textDocument = {
                    completion = {
                        completionItem = {
                            snippetSupport = true,
                        },
                    }
                }
            }
        ),
        flags = {
            debounce_text_changes = 150,
        }
    }
)

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
nmap('[d', vim.diagnostic.goto_prev, {}, 'Go to previous diagnostic')
nmap(']d', vim.diagnostic.goto_next, {}, 'Go to next diagnostic')
nmap('<Space>d', vim.diagnostic.open_float, {}, 'Preview diagnostic')
nmap('<Space>q', vim.diagnostic.setloclist, {}, 'Open loclist')
-- toggle diagnostics
nmap('yoD',
    function()
        vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    end,
    {}, 'diagnostics')
nmap(']oD', function() vim.diagnostic.enable(false) end, {}, 'diagnostics')
nmap('>oD', function() vim.diagnostic.enable(false) end, {}, 'diagnostics')
nmap('[oD', vim.diagnostic.enable, {}, 'diagnostics')
nmap('<oD', vim.diagnostic.enable, {}, 'diagnostics')

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
local ag_UserLspConfig = vim.api.nvim_create_augroup('UserLspConfig', {})
vim.api.nvim_create_autocmd('LspAttach', {
    group = ag_UserLspConfig,
    callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        -- Enable completion triggered by <c-x><c-o>
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap = true, silent = true, buffer = bufnr }

        local filtered_goto = function(name)
            return function()
                local callback = vim.lsp.buf[name]
                local filter = vim.b[bufnr].lsp_goto_filter
                if filter then
                    callback({
                        on_list = function(opts)
                            local filtered_opts = filter(name, opts)
                            vim.fn.setqflist({}, ' ', filtered_opts)
                            if #filtered_opts.items > 1 then
                                vim.cmd.copen()
                            else
                                vim.cmd.cfirst()
                            end
                        end
                    })
                else
                    callback()
                end
            end
        end

        vim.print(vim.lsp.buf.definition)

        -- goto
        nmap('gd', filtered_goto('definition'), bufopts, 'Go to definition')
        nmap('gD', filtered_goto('declaration'), bufopts, 'Go to declaration')
        nmap('gI', filtered_goto('implementation'), bufopts, 'Show implementations')
        nmap('gr', filtered_goto('references'), bufopts, 'Show references ')
        nmap('gT', filtered_goto('type_definition'), bufopts, 'Go to type definition')

        -- under cursor
        nmap('K', vim.lsp.buf.hover, bufopts)
        nmap('<C-k>', vim.lsp.buf.signature_help, bufopts)
        nmap('<space>r', vim.lsp.buf.rename, bufopts, 'Rename')
        -- nmap('<space>ca', vim.lsp.buf.code_action, bufopts)
        nmap('<space>c', vim.cmd.CodeActionMenu, bufopts, 'Code Action')

        -- global actions
        nmap('<space>f', format, bufopts, 'Format')

        -- LSP workspace
        wk.register({ ['<space>w'] = { name = "Workspace" }, { buffer = bufnr } })
        nmap('<space>wa', vim.lsp.buf.add_workspace_folder, bufopts, 'Add workspace folder')
        nmap('<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts, 'Remove workspace folder')
        nmap('<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts, 'List workspace folders')

        lsp_status.on_attach(client)
    end,
})
au("BufWritePre", { callback = format })

require("copilot").setup({
    panel = { enabled = false },
    suggestion = { enabled = false, auto_trigger = true },
    copilot_node_command = "/usr/local/opt/node@20/bin/node",
})
require("copilot_cmp").setup()
require("CopilotChat").setup()

local snippy = require('snippy')

o.completeopt = { 'menuone', 'noselect', 'preview' }
cmp.setup({
    experimental = {
        ghost_text = { hl_group = 'Suggestion' },
    },
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        -- Select the [n]ext item
        ['<C-n>'] = cmp.mapping.select_next_item(),
        -- Select the [p]revious item
        ['<C-p>'] = cmp.mapping.select_prev_item(),

        -- Scroll the documentation window [b]ack / [f]orward
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

        -- Accept ([y]es) the completion.
        --  This will auto-import if your LSP supports it.
        --  This will expand snippets if the LSP sent a snippet.
        ['<C-y>'] = cmp.mapping.confirm { select = true },
        ['<C-l>'] = cmp.mapping(function(fallback)
            if snippy.can_expand_or_advance() then
                snippy.expand_or_advance()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function(fallback)
            if snippy.can_jump(-1) then
                snippy.previous()
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
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
    sorting = {
        priority_weight = 2,
        comparators = {
            require("copilot_cmp.comparators").prioritize,
            -- Below is the default comparitor list and order for nvim-cmp
            cmp.config.compare.offset,
            -- cmp.config.compare.scopes, -- this is commented in nvim-cmp too
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
    -- Pictograms
    formatting = {
        format = lspkind.cmp_format({
            before = require("tailwind-tools.cmp").lspkind_format,
            -- before = function(entry, vim_item)
            --     if entry.source.name == 'nvim_lsp' then
            --         -- Display which LSP servers this item came from.
            --         local lspserver_name = nil
            --         pcall(function()
            --             lspserver_name = entry.source.source.client.name
            --             if vim_item then
            --                 vim_item.menu = lspserver_name
            --             end
            --         end)
            --     end
            --     return vim_item
            -- end,
            mode = 'symbol_text',
            symbol_map = { Copilot = "", Color = "󰝤" },
            maxwidth = 150,        -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
        })
    },
    window = {
        documentation = {
            border = default_border,
            winhighlight = '',
        },
        completion = {
            border = default_border,
            winhighlight = '',
        },
    },
})

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done()
)

vim.api.nvim_create_autocmd('BufEnter', {
    pattern = 'copilot-*',
    callback = function()
        cmp.setup.buffer({
            enabled = false,
        })
    end
})

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
    ),
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    }),
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
        border = default_border,
    },
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    worktrees = {
        {
            toplevel = vim.env.HOME,
            gitdir = vim.env.HOME .. '/.dotfiles.git'
        },
    },
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
wk.register({ ['<leader>h'] = { name = "Git [H]unks" } })
map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', 'Stage hunk')
map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', 'Reset hunk')
map('n', '<leader>hu', gitsigns.undo_stage_hunk, 'Undo staged hunk')
map('n', '<leader>hS', gitsigns.stage_buffer, 'Stage buffer')
map('n', '<leader>hR', gitsigns.reset_buffer, 'Reset buffer')
map('n', '<leader>hh', gitsigns.preview_hunk, 'Preview hunk')
map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, 'Show git blame')
map('n', '<leader>hd', gitsigns.diffthis, 'Diff from index')
map('n', '<leader>hD', function() gitsigns.diffthis('~') end, 'Diff from HEAD~')

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
                file_status = true,    -- Displays file status (readonly status, modified status)
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
            {
                -- show the virtual environment name
                function()
                    if (vim.env.VIRTUAL_ENV_PROMPT or "") ~= "" then
                        return vim.env.VIRTUAL_ENV_PROMPT:gsub("%s+", "")
                    end

                    local venv = vim.fs.basename(vim.env.VIRTUAL_ENV or "")
                    if venv == ".venv" then
                        venv = vim.fs.basename(vim.fs.dirname(vim.env.VIRTUAL_ENV or ""))
                    end
                    if venv ~= "" then
                        return venv
                    end
                    return ""
                end,
            },
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
}
-- }}}

--{{{ json/yaml
au('FileType', {
    pattern = { 'yaml' },
    callback = function()
        vim.bo.expandtab = true
        vim.bo.softtabstop = 2
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.iskeyword = vim.bo.iskeyword .. ',-'
    end
})

lspconfig.yamlls.setup({
    settings = {
        yaml = {
            keyOrdering = false,
            schemas = require('schemastore').yaml.schemas(),
        },
    },
})
lspconfig.jsonls.setup({
    settings = {
        json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
        },
    },
})
--}}}

-- {{{ php
local wp = require('wordpress')

lspconfig.intelephense.setup(wp.intelephense)

lsp_formatters['php'] = { 'html', 'null-ls' }
lsp_formatters['php.wp'] = lsp_formatters['php']

table.insert(null_ls_sources, null_ls.builtins.diagnostics.phpcs.with(wp.null_ls_phpcs))
table.insert(null_ls_sources, null_ls.builtins.formatting.phpcbf.with(wp.null_ls_phpcs))

au('FileType', {
    pattern = { '*.wp' },
    callback = function()
        local _listchars = vim.deepcopy(listchars)
        _listchars['tab'] = '  '
        vim.b.listchars = _listchars
    end
})
-- }}}

--{{{ html/css/js
lspconfig.html.setup({
    filetypes = { 'html', 'templ', 'htmldjango' },
    -- https://github.com/microsoft/vscode-docs/blob/cccc58b6e71c71ff843d401f67a3424a2e131ef9/docs/languages/html.md#formatting
    settings = {
        html = {
            format = {
                templating = true,
            }
        }
    },
})

-- lspconfig.cssls.setup({})
lspconfig.tailwindcss.setup({
    on_attach = function(client, bufnr)
        client.server_capabilities.completionProvider.triggerCharacters = { '"', "'", "`", ".", "(", "[", "!", "/", ":" }
    end,
    filetypes = { 'html', 'htmldjango', 'php', 'php.wp', 'javascript', 'javascript.wp', 'typescript', 'javascriptreact',
        'typescriptreact' },
    init_options = {
        userLanguages = {
            ["php.wp"] = "html",
            ["javascript.wp"] = "javascript",
        }
    },
    settings = {
        tailwindCSS = {
            experimental = {
                classRegex = {
                    { [[body_class(.*)]], [[(?:'|")([^"']*)(?:'|")]] },
                    { [[array(.*)]],      [[(?:'|")([^"']*)(?:'|")]] },
                }
            }
        }
    }
})

require("tailwind-tools").setup({
    document_color = {
        enabled = false,
        kind = "background",
    },
    conceal = {
        enabled = false,
    },
    custom_filetypes = { 'php.wp', 'javascript.wp' },
})

lspconfig.eslint.setup({
    filetypes = table.insert(lspconfig.eslint.document_config.default_config.filetypes, 'javascript.wp'),
})
lspconfig.tsserver.setup({
    filetypes = table.insert(lspconfig.tsserver.document_config.default_config.filetypes, 'javascript.wp'),
})
table.insert(null_ls_sources, null_ls.builtins.formatting.prettier.with({
    disabled_filetypes = { "html" }, -- format with html language server instead
    extra_args = function(params)
        return params.options
            and params.options.tabSize
            and {
                "--tab-width",
                params.options.tabSize,
            }
    end,
}))

lsp_formatters['javascript'] = { 'null-ls' }
lsp_formatters['javascript.wp'] = lsp_formatters['javascript']

--}}}

-- {{{ go
au('FileType', {
    pattern = { 'go' },
    callback = function()
        local _listchars = vim.deepcopy(listchars)
        _listchars['tab'] = '  '
        vim.b.listchars = _listchars
    end
})

lspconfig.gopls.setup({})
table.insert(null_ls_sources, null_ls.builtins.diagnostics.golangci_lint.with {
    prefer_local = 'bin',
})
-- }}}

-- {{{ python
vim.api.nvim_create_autocmd('LspAttach', {
    group = ag_UserLspConfig,
    callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        if client.name ~= 'pyright' then
            return
        end

        vim.b[bufnr].lsp_goto_filter = function(name, opts)
            local sources = {}
            local stubs = {}

            for _, item in ipairs(opts.items) do
                local extension = vim.fn.fnamemodify(item.filename, ':e')
                if extension == 'pyi' then
                    table.insert(stubs, item)
                else
                    table.insert(sources, item)
                end
            end

            if 'definition' == name and #sources >= 1 then
                opts.items = sources
            elseif 'declaration' == name and #stubs >= 1 then
                opts.items = stubs
            end

            return opts
        end

        -- -- Buffer local mappings.
        -- -- See `:help vim.lsp.*` for documentation on any of the below functions
        -- local bufopts = { noremap = true, silent = true, buffer = bufnr }

        -- -- goto
        -- nmap('gd', function()
        --     vim.lsp.buf.definition({
        --         on_list = function(opts)
        --             vim.print(vim.inspect(opts))
        --         end
        --     })
        -- end, bufopts, 'Go to definition')

        -- nmap('gD', vim.lsp.buf.declaration, bufopts, 'Go to declaration')
        -- nmap('gI', vim.lsp.buf.implementation, bufopts, 'Show implementations')
        -- nmap('gr', vim.lsp.buf.references, bufopts, 'Show references ')
        -- nmap('gT', vim.lsp.buf.type_definition, bufopts, 'Go to type definition')
    end
})

lspconfig.pyright.setup({
    settings = {
        python = {
            analysis = {
                diagnosticSeverityOverrides = {
                    reportUndefinedVariable = 'none',
                }
            },
        },
    },
})
lspconfig.ruff_lsp.setup({})
-- }}}

-- {{{ lua
lspconfig.lua_ls.setup({
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
        },
    },
})

au('FileType', {
    pattern = { 'lua' },
    callback = function()
        vim.b.surround_45 = '[[[ \\r ]]]'
        vim.b.surround_109 = '[[[ \\r ]]]'
    end
})
-- }}}

--{{{ Bash, shell, docker

lspconfig.bashls.setup({})
lspconfig.dockerls.setup({})
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
npairs.cond = require 'nvim-autopairs.conds'
npairs.setup({
    enable_check_bracket_line = true,
})

-- Add spaces between parentheses
local brackets = { { '(', ')' }, { '[', ']' }, { '{', '}' } }
npairs.add_rules {
    npairs.Rule(' ', ' ')
        :with_pair(function(opts)
            local pair = opts.line:sub(opts.col - 1, opts.col)
            return vim.tbl_contains({
                brackets[1][1] .. brackets[1][2],
                brackets[2][1] .. brackets[2][2],
                brackets[3][1] .. brackets[3][2]
            }, pair)
        end)
        :with_move(npairs.cond.none())
        :with_cr(npairs.cond.none())
        :with_del(function(opts)
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local context = opts.line:sub(col - 1, col + 2)
            return vim.tbl_contains({
                brackets[1][1] .. '  ' .. brackets[1][2],
                brackets[2][1] .. '  ' .. brackets[2][2],
                brackets[3][1] .. '  ' .. brackets[3][2]
            }, context)
        end)
}
for _, bracket in pairs(brackets) do
    npairs.Rule('', ' ' .. bracket[2])
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
        'php', 'phpdoc',
        'python', 'htmldjango',
        'lua',
        'c', 'cpp', 'c_sharp',
        'javascript', 'typescript', 'tsx', 'jq',
        'html', 'css',
        'sql',
        'vim',
        'markdown', 'comment', 'dot',
        'bash', 'dockerfile', 'make', 'diff', 'awk',
        'git_rebase', 'gitignore', 'gitattributes', 'gitcommit',
        'json', 'jsonc', 'yaml', 'toml', 'hcl', 'jsonnet',
        'proto',
    },

    -- ignore_install = {
    --     "phpdoc", -- wait until claytonrcarter/tree-sitter-phpdoc#1 is completed
    -- },

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
--}}}

-- {{{ null-ls
null_ls.setup({
    debug = true,
    log_level = "trace",
    sources = null_ls_sources,
    border = default_border,
    update_in_insert = false,
})
-- }}}

-- vim:foldmethod=marker:foldlevel=0
