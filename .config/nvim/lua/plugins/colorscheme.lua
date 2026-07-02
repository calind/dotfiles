local selenized_dev_path = vim.fn.expand('~/work/src/github.com/calind/selenized.nvim')

return {
    {
        'calind/selenized.nvim',
        dev = vim.fn.isdirectory(selenized_dev_path) == 1,
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme 'selenized'
        end,
    },
}
