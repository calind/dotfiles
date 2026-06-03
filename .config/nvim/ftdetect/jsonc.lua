vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = {
        '*.cjson',
        'coc-settings.json',
        '*.jsonc',
        '.eslintrc.json',
        '.babelrc',
        '.jshintrc',
        '.jslintrc',
        '.mocharc.json',
        'coffeelint.json',
        'tsconfig*.json',
        'jsconfig.json',
        '*/.vscode/*.json',
        'renovate*.json',
    },
    callback = function()
        vim.bo.filetype = 'jsonc'
    end,
})
