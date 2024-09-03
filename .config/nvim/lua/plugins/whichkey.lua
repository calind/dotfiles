local ui = require('custom.ui')

return {
    {
        'folke/which-key.nvim',
        tag = 'v2.1.0',
        opts = {
            plugins = {
                spelling = {
                    enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                    suggestions = 10, -- how many suggestions should be shown in the list?
                },
            },
            operators = {
                [']x'] = 'XML encode',
                ['[x'] = 'XML decode',
                [']u'] = 'URL encode',
                ['[u'] = 'URL decode',
                [']y'] = 'C string encode',
                ['[y'] = 'C string decode',
                [']C'] = 'C string encode',
                ['[C'] = 'C string decode',
                ['ga'] = 'Align',
                ['gA'] = 'Align with preview',
                ['gc'] = 'Comment',
                ['gq'] = 'Format',
                ['gw'] = 'Text format',
            },
            window = {
                border = ui.border,
                margin = { 1, 10, 1, 10 },
                padding = { 1, 0, 1, 0 },
            },
        },
        config = function(_, opts)
            local wk = require('which-key')
            wk.setup(opts)
            wk.register({
                gqq = 'Format current line',
                gww = 'Text format current line',
            }, {
                mode = { 'n' }
            })
            wk.register({
                gqq = 'Format selected lines',
                gww = 'Text format selected lines',
            }, {
                mode = { 'v' }
            })
        end
    },
}
