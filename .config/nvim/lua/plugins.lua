local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end
local packer_bootstrap = ensure_packer()

vim.cmd([[
    augroup packer_user_config
        autocmd!
        autocmd BufWritePost plugins.lua source <afile> | PackerSync
    augroup end
]])

return require('packer').startup({
    function(use)
        use 'wbthomason/packer.nvim'

        use 'lewis6991/impatient.nvim'

        use 'tpope/vim-repeat'
        use 'tpope/vim-commentary'
        use 'tpope/vim-surround'
        use 'tpope/vim-unimpaired'

        use 'junegunn/vim-easy-align'

        use 'folke/which-key.nvim'

        use 'nvim-lua/plenary.nvim'

        use 'nvim-lualine/lualine.nvim'

        use ({
            'lambdalisue/suda.vim',
            config = function()
                vim.g.suda_smart_edit = 1
            end
        })

        use({
            -- Autocomplete
            'hrsh7th/nvim-cmp',
            requires = {
                -- LSP
                'neovim/nvim-lspconfig',
                'nvim-lua/lsp-status.nvim',

                -- Autocmplete
                'hrsh7th/cmp-path',
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-cmdline',
                'hrsh7th/cmp-git',
                'hrsh7th/cmp-calc',
                'hrsh7th/cmp-nvim-lsp-document-symbol',
                -- 'hrsh7th/cmp-nvim-lsp-signature-help',

                -- Snippets
                'hrsh7th/cmp-vsnip',
                'hrsh7th/vim-vsnip',
                'rafamadriz/friendly-snippets',

                -- LSP & autocomplete UI
                'onsails/lspkind-nvim',
                'kosayoda/nvim-lightbulb',
                'weilbith/nvim-code-action-menu',
                -- 'ray-x/lsp_signature.nvim',

                'jose-elias-alvarez/null-ls.nvim',

                use({ 'zbirenbaum/copilot-cmp', requires = { 'zbirenbaum/copilot.lua' } }),
            },

            use 'lewis6991/gitsigns.nvim',

            use 'nvim-treesitter/nvim-treesitter',
            use 'nvim-treesitter/playground',

            use 'windwp/nvim-autopairs',

            use 'micarmst/vim-spellsync',
        })

        -- Automatically set up your configuration after cloning packer.nvim
        -- Put this at the end after all plugins
        if packer_bootstrap then
            require('packer').sync()
        end
    end,
    config = {
        display = {
            open_fn = function() return require('packer.util').float({ border = heavy_border }) end,
        }
    }
})
