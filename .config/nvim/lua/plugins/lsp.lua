local ui = require('custom.ui')

return {
    'neovim/nvim-lspconfig',
    dependencies = {

        'b0o/schemastore.nvim',

        'nvimtools/none-ls.nvim',
        'mason-org/mason.nvim',
        'mason-org/mason-lspconfig.nvim',
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
                custom_filetypes = { 'php.wp', 'javascript.wp', 'css', 'templ' },
            }
        },
        { 'folke/neodev.nvim',      opts = {} },
        { 'bitpoke/wordpress.nvim', dev = true, opts = {} },
        { 'towolf/vim-helm',        ft = 'helm' },
        'fladson/vim-kitty',
        {
            'ghostty-macos',
            dir = '/Applications/Ghostty.app/Contents/Resources/nvim/site/',
            cond = function()
                return vim.fn.has('macunix') and vim.fn.executable('ghostty') == 1
            end,
        },
    },
    config = function()
        local lsp = require('custom.lsp')
        local lspconfig = require('lspconfig')
        local null_ls = require('null-ls')
        local null_ls_sources = {}
        local lightbulb = require('nvim-lightbulb')

        -- setup UI
        local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
        ---@diagnostic disable-next-line: duplicate-set-field
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = ui.border
            return orig_util_open_floating_preview(contents, syntax, opts, ...)
        end

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
                text = {
                    [vim.diagnostic.severity.ERROR] = ui.signs.Error,
                    [vim.diagnostic.severity.WARN] = ui.signs.Warn,
                    [vim.diagnostic.severity.INFO] = ui.signs.Info,
                    [vim.diagnostic.severity.HINT] = ui.signs.Hint,
                },
            },
            severity_sort = true,
        })

        vim.g.code_action_menu_window_border = ui.border

        -- first, setup mason
        require('mason').setup({
            ui = {
                border = ui.border,
                backdrop = 100,
            }
        })
        require('mason-lspconfig').setup({ automatic_enable = true })
        require('mason-null-ls').setup({ automatic_installation = { exclude = { 'phpcs', 'phpcbf' } } })


        vim.api.nvim_create_autocmd('BufWritePre', { callback = function() lsp.buf.format() end })

        -- Language servers

        -- YAML/json
        vim.lsp.config('yamlls', {
            settings = {
                yaml = {
                    keyOrdering = false,
                    schemas = require('schemastore').yaml.schemas(),
                },
            },
        })
        vim.lsp.config('jsonls', {
            settings = {
                json = {
                    schemas = require('schemastore').json.schemas(),
                    validate = { enable = true },
                },
            },
        })

        -- Lua
        vim.lsp.config('lua_ls', {
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
        vim.lsp.config('intelephense', vim.tbl_extend('force', wp.intelephense, {
            -- the original intelephense root dir functions, sets the root to cwd if .git or composer.json is a descendant
            -- that means that if you open a file from $HOME, even though the file is in a git repo, the root will be $HOME
            -- which is not what I want
            -- root_dir = lspconfig.util.root_pattern('composer.json', '.git'),
            init_options = {
                globalStoragePath = vim.fn.stdpath('data') .. '/intelephense/',
                storagePath = vim.fn.stdpath('cache') .. '/intelephense/',
            }
        }))

        table.insert(null_ls_sources, null_ls.builtins.diagnostics.phpcs.with(wp.null_ls_phpcs))
        table.insert(null_ls_sources, null_ls.builtins.formatting.phpcbf.with(wp.null_ls_phpcs))

        -- html/css/js
        vim.lsp.config('html', {
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

        vim.lsp.config('eslint', {
            filetypes = table.insert(lspconfig.eslint.document_config.default_config.filetypes, 'javascript.wp'),
        })
        vim.lsp.config('ts_ls', {
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

        vim.lsp.config('tailwindcss', {
            on_attach = function(client, _)
                -- https://github.com/hrsh7th/nvim-cmp/issues/1828#issuecomment-1985851622
                client.server_capabilities.completionProvider.triggerCharacters = {
                    '"', "'", '`', '.', '(', '[', '!', '/', ':'
                }
            end,
            filetypes = {
                'html', 'htmldjango', 'php', 'php.wp', 'javascript', 'javascript.wp',
                'typescript', 'javascriptreact', 'typescriptreact', 'css', 'templ'
            },
            init_options = {
                userLanguages = {
                    ['templ'] = 'html',
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
                            { [[Class(.*)]],         [[(?:'|")([^"']*)(?:'|")]] },
                        }
                    }
                }
            }
        })

        vim.lsp.config('gopls', {})
        -- vim.lsp.config('gopls_proxy', {
        --     cmd = { 'go', 'run', '/Users/calin/work/src/github.com/calind/lsp-proxy/cmd/fw/main.go', '/Users/calin/.local/share/nvim/mason/bin/gopls' },
        --     filetypes = { 'go' },
        --     root_markers = { '.git', 'go.mod' },
        -- })
        -- vim.lsp.enable('gopls_proxy')
        -- vim.lsp.set_log_level('debug')
        vim.lsp.config('templ', {})
        vim.lsp.config('pyright', {
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
        vim.lsp.config('ruff', {})

        -- Bash, shell, docker, kubernetes

        vim.lsp.config('bashls', {})
        vim.lsp.config('dockerls', {})
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

        -- Terraform
        vim.lsp.config('terraformls', {})

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
                    otter.activate({ 'javascript' })
                end
            })
        end
    end
}
