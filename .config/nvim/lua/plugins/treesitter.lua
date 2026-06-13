-- :TSInstall go gomod templ php phpdoc python htmldjango lua c cpp c_sharp javascript typescript tsx jq html css sql vim markdown markdown_inline comment dot bash dockerfile make diff awk git_rebase gitignore gitattributes gitcommit hcl terraform json jsonc yaml toml hcl jsonnet proto helm

local languages = {
    'go', 'gomod', 'templ',
    'php', 'phpdoc',
    'python', 'htmldjango',
    'lua',
    'c', 'cpp', 'c_sharp',
    'javascript', 'typescript', 'tsx', 'jq',
    'html', 'css',
    'sql',
    'vim',
    'markdown', 'markdown_inline', 'comment', 'dot',
    'bash', 'dockerfile', 'make', 'diff', 'awk',
    'git_rebase', 'gitignore', 'gitattributes', 'gitcommit',
    'hcl', 'terraform',
    'json', 'jsonc', 'yaml', 'toml', 'hcl', 'jsonnet',
    'proto',
    'helm',
}

return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        lazy = false,
        init = function()
            vim.api.nvim_create_autocmd('FileType', {
                pattern = languages,
                callback = function()
                    vim.print('Loading treesitter for ' .. vim.bo.filetype)
                    vim.treesitter.start()
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },
    'nvim-treesitter/nvim-treesitter-textobjects',
}
