local ui = require('custom.ui')
return {
    -- functional libraries
    'nvim-lua/plenary.nvim',
    {
        'johmsalas/text-case.nvim',
        lazy = false,
        config = function()
            _G.textcase = require('textcase').api
        end
    },

    -- absolute utilities
    'micarmst/vim-spellsync',
    'mbbill/undotree',
    {
        'lambdalisue/suda.vim',
        config = function()
            vim.g.suda_smart_edit = 1
        end
    },

    {
        'junegunn/vim-easy-align',
        config = function()
            local wk = require('which-key')
            wk.register({
                ga = {
                    '<Plug>(EasyAlign)',
                    'Align',
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
        end
    },

    'tpope/vim-repeat',
    {
        'tpope/vim-surround',
        config = function()
            local wk = require('which-key')
            local surrounds = {
                t = 'Tag (eg. <div>)',
                b = 'Parentheses (trim) - same as (',
                B = 'Parentheses - same as )',
                ['('] = 'Parentheses (trim)',
                [')'] = 'Parentheses',
                ['<'] = 'Angle brackets (trim)',
                ['>'] = 'Angle brackets',
                ['['] = 'Square brackets (trim)',
                [']'] = 'Square brackets',
                ['{'] = 'Curly braces (trim)',
                ['}'] = 'Curly braces',
                ["'"] = 'Single quotes',
                ['"'] = 'Double quotes',
                ['`'] = 'Backticks',
            }
            local objects = {
                w = { name = 'word (with whitespace)', surrounds },
                W = { name = 'WORD', surrounds },
                s = { name = 'sentence', surrounds },
                p = { name = 'paragraph', surrounds },
            }
            wk.register({
                cs = { name = 'Surrounding', surrounds },
                cS = { name = 'Surrounding (with \n)', surrounds },
                ds = { name = 'Surrounding', surrounds },
                ys = { name = 'Surrounding', objects },
                yS = { name = 'Surrounding (with \n)', objects },
                yss = { name = 'Surrounding line', surrounds },
                ySs = { name = 'Surrounding line (with \n)', surrounds },
                ySS = { name = 'Surrounding line (with \n)', surrounds },
            }, {
                mode = 'n',
                noremap = true,
            })
            wk.register({
                gS = { name = 'Insert surrounds (with \n)', surrounds },
            }, {
                mode = 'v',
                noremap = true,
            })
        end
    },
    {
        'echasnovski/mini.nvim',
        version = false,
        config = function()
            local spec_treesitter = require('mini.ai').gen_spec.treesitter
            require('mini.ai').setup({
                custom_textobjects = {
                    F = spec_treesitter({ a = '@function.outer', i = '@function.inner' }),
                    o = spec_treesitter({
                        a = { '@conditional.outer', '@loop.outer' },
                        i = { '@conditional.inner', '@loop.inner' },
                    })
                }
            })
            require('mini.sessions').setup()
            require('mini.comment').setup()
            require('mini.notify').setup({
                window = {
                    config = {
                        border = ui.border
                    },
                },
            })
            require('mini.pick').setup({
                window = {
                    config = {
                        border = ui.border
                    },
                },
            })
            vim.ui.select = require('mini.pick').ui_select
            require('mini.icons').setup({})
        end
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        config = function()
            require('render-markdown').setup({
                file_types = { 'markdown', 'codecompanion', 'copilot-chat' },
                overrides = {
                    buftype = {
                        nofile = {
                            code = { style = 'normal', disable_background = true, left_pad = 0, right_pad = 0 },
                        },
                    },
                    filetype = {
                        ['copilot-chat'] = {
                            anti_conceal = {
                                enabled = false,
                            },
                            heading = {
                                position = 'inline',
                                icons = { ' ' }
                            }
                        }
                    }
                }
            })
        end
    },
}
