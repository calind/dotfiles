local ui = require('custom.ui')

return {
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-cmdline',
            'petertriho/cmp-git',
            'hrsh7th/cmp-calc',
            'hrsh7th/cmp-nvim-lsp-document-symbol',

            'dcampos/nvim-snippy',
            'dcampos/cmp-snippy',
            'honza/vim-snippets',
        },
        config = function()
            local cmp = require('cmp')
            local snippy = require('snippy')

            require('cmp_git').setup()

            vim.opt.completeopt = { 'menuone', 'noselect', 'preview' }
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
                        { name = 'git' },
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
                        require('copilot_cmp.comparators').prioritize,
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
                    format = ui.cmp_format
                },
                window = {
                    documentation = {
                        border = ui.border,
                        winhighlight = '',
                    },
                    completion = {
                        border = ui.border,
                        winhighlight = '',
                    },
                },
            })

            local ok, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
            if ok then
                cmp.event:on(
                    'confirm_done',
                    cmp_autopairs.on_confirm_done()
                )
            end

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
        end
    },
}
