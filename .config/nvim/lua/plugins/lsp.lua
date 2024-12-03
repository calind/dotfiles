local ui = require('custom.ui')

-- local function capabilities(override)
--     override = override or {}
--     vim.print(vim.inspect(override))
--     local ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
--     if ok then
--         override = cmp_lsp.default_capabilities(override)
--     end
--
--     return override
-- end

local function create_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    -- this is a fix for nvim 10 - it appears that cmp_nvim_lsp was overwriting
    -- the capabilities.textDocument which caused errors in json-lsp
    capabilities.textDocument.completion = {
        dynamicRegistration = false,
        completionItem = {
            snippetSupport = true,
            commitCharactersSupport = true,
            deprecatedSupport = true,
            preselectSupport = true,
            tagSupport = {
                valueSet = {
                    1, -- Deprecated
                },
            },
            insertReplaceSupport = true,
            resolveSupport = {
                properties = {
                    'documentation',
                    'detail',
                    'additionalTextEdits',
                    'sortText',
                    'filterText',
                    'insertText',
                    'textEdit',
                    'insertTextFormat',
                    'insertTextMode',
                },
            },
            insertTextModeSupport = {
                valueSet = {
                    1, -- asIs
                    2, -- adjustIndentation
                },
            },
            labelDetailsSupport = true,
        },
        contextSupport = true,
        insertTextMode = 1,
        completionList = {
            itemDefaults = {
                'commitCharacters',
                'editRange',
                'insertTextFormat',
                'insertTextMode',
                'data',
            },
        },
    }

    return capabilities

    -- return cmp_lsp.default_capabilities(capabilities.textDocument)
end

return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',

        'b0o/schemastore.nvim',

        'nvimtools/none-ls.nvim',
        'jay-babu/mason-null-ls.nvim',

        'nvim-lua/lsp-status.nvim',
        'kosayoda/nvim-lightbulb',
        'weilbith/nvim-code-action-menu',

        'jmbuhr/otter.nvim',

        {
            'luckasRanarison/tailwind-tools.nvim',
            dev = true,
            opts = {
                document_color = {
                    enabled = false,
                    kind = 'background',
                },
                conceal = {
                    enabled = false,
                },
                custom_filetypes = { 'php.wp', 'javascript.wp', 'css' },
            }
        },
        { 'folke/neodev.nvim',      opts = {} },
        { 'bitpoke/wordpress.nvim', dev = true },
        'towolf/vim-helm',
        'fladson/vim-kitty',
    },
    config = function()
        local lsp = require('custom.lsp')
        local lspconfig = require('lspconfig')
        local null_ls = require('null-ls')
        local null_ls_sources = {}
        local lightbulb = require('nvim-lightbulb')

        -- setup UI
        require('lspconfig.ui.windows').default_options.border = ui.border
        lightbulb.setup({
            sign = { enabled = false },
            status_text = { enabled = true, text = ui.signs.LightBulb },
            autocmd = {
                enabled = true
            }
        })
        vim.diagnostic.config({
            float = {
                border = ui.border,
            },
            virtual_text = {
                source = true,
            },
            signs = {
                priority = 50,
            },
            severity_sort = true,
        })

        vim.g.code_action_menu_window_border = ui.border

        lspconfig.util.default_config = vim.tbl_extend('force', lspconfig.util.default_config, {
            handlers = {
                ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = ui.border }),
                ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = ui.border }),
            },
            capabilities = create_capabilities(),
        })

        -- first, setup mason
        require('mason').setup({
            ui = {
                border = ui.border,
            }
        })
        require('mason-lspconfig').setup({ automatic_installation = true })
        require('mason-null-ls').setup({ automatic_installation = { exclude = { 'phpcs', 'phpcbf' } } })

        vim.api.nvim_create_autocmd('BufWritePre', { callback = function() lsp.buf.format() end })

        -- Language servers

        -- YAML/json
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

        -- Lua
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

        -- PHP (with WordPress support)
        local wp = require('wordpress')
        lspconfig.intelephense.setup(wp.intelephense)
        table.insert(null_ls_sources, null_ls.builtins.diagnostics.phpcs.with(wp.null_ls_phpcs))
        table.insert(null_ls_sources, null_ls.builtins.formatting.phpcbf.with(wp.null_ls_phpcs))

        -- html/css/js
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

        lspconfig.eslint.setup({
            filetypes = table.insert(lspconfig.eslint.document_config.default_config.filetypes, 'javascript.wp'),
        })
        lspconfig.ts_ls.setup({
            filetypes = table.insert(lspconfig.ts_ls.document_config.default_config.filetypes, 'javascript.wp'),
        })
        table.insert(null_ls_sources, null_ls.builtins.formatting.prettier.with({
            disabled_filetypes = { 'html' }, -- format with html language server instead
            extra_args = function(params)
                return params.options
                    and params.options.tabSize
                    and {
                        '--tab-width',
                        params.options.tabSize,
                    }
            end,
        }))

        lspconfig.tailwindcss.setup({
            on_attach = function(client, _)
                -- https://github.com/hrsh7th/nvim-cmp/issues/1828#issuecomment-1985851622
                client.server_capabilities.completionProvider.triggerCharacters = {
                    '"', "'", '`', '.', '(', '[', '!', '/', ':'
                }
            end,
            filetypes = {
                'html', 'htmldjango', 'php', 'php.wp', 'javascript', 'javascript.wp',
                'typescript', 'javascriptreact', 'typescriptreact', 'css'
            },
            init_options = {
                userLanguages = {
                    ['php.wp'] = 'html',
                    ['javascript.wp'] = 'javascript',
                }
            },
            settings = {
                tailwindCSS = {
                    experimental = {
                        classRegex = {
                            { [[body_class(.*)]],    [[(?:'|")([^"']*)(?:'|")]] },
                            { [[array(.*)]],         [[(?:'|")([^"']*)(?:'|")]] },
                            { [['[^']+_class'(.*)]], [[(?:'|")([^"']*)(?:'|")]] },
                        }
                    }
                }
            }
        })

        lspconfig.gopls.setup({})
        table.insert(null_ls_sources, null_ls.builtins.diagnostics.golangci_lint.with {
            prefer_local = 'bin',
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
        lspconfig.ruff.setup({})

        -- Bash, shell, docker, kubernetes

        lspconfig.bashls.setup({})
        lspconfig.dockerls.setup({})
        table.insert(null_ls_sources, null_ls.builtins.diagnostics.hadolint)

        lspconfig.helm_ls.setup {
            settings = {
                ['helm-ls'] = {
                    yamlls = {
                        path = 'yaml-language-server',
                    }
                }
            }
        }

        -- none-ls
        null_ls.setup({
            debug = true,
            log_level = 'trace',
            sources = null_ls_sources,
            border = ui.border,
            update_in_insert = false,
        })

        -- otter
        local ok, otter = pcall(require, 'otter')
        if ok then
            otter.setup({
                lsp = {
                    border = ui.border,
                },
                buffers = {
                    set_filetype = true,
                },
            })
            vim.api.nvim_create_autocmd('FileType', {
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
        end
    end
}
