return {
    {
        'windwp/nvim-autopairs',
        config = function()
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
        end,
    }
}
