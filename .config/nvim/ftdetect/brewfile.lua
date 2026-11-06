vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = {
        'Brewfile',
        'Brewfile.*',
        '*.Brewfile',
        '.Brewfile.*',

    },
    callback = function()
        if vim.api.nvim_buf_get_name(0):find('Brewfile') then
            vim.bo.filetype = 'ruby'
            vim.bo.syntax = 'brewfile'
        end
    end,
})
