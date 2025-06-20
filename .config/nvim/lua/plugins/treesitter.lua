return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        lazy = false,
        config = function()
            require('nvim-treesitter.configs').setup {
                -- A list of parser names, or 'all'
                ensure_installed = {
                    'go', 'gomod',
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
                },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                highlight = {
                    -- `false` will disable the whole extension
                    enable = true,
                    -- disable slow treesitter highlight for large files
                    disable = function(_, buf)
                        local max_filesize = 100 * 1024 -- 100 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end,
                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
            }
        end
    },
    'nvim-treesitter/nvim-treesitter-textobjects',
}
