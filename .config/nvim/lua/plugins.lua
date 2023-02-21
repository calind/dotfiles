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
        autocmd BufWritePost plugins.lua source <afile> | PackerCompile
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

        use 'micarmst/vim-spellsync'

        use 'folke/which-key.nvim'

        use 'nvim-lua/plenary.nvim'

        use 'nvim-lualine/lualine.nvim'

        use({
            'johmsalas/text-case.nvim',
            config = function()
                _G.textcase = require('textcase').api
            end
        })

        use({
            'lambdalisue/suda.vim',
            config = function()
                vim.g.suda_smart_edit = 1
            end
        })

        -- LSP
        use 'neovim/nvim-lspconfig'
        use 'nvim-lua/lsp-status.nvim'
        use 'jose-elias-alvarez/null-ls.nvim'

        -- Autocmplete
        use 'hrsh7th/nvim-cmp'
        use 'hrsh7th/cmp-path'
        use 'hrsh7th/cmp-buffer'
        use 'hrsh7th/cmp-nvim-lsp'
        use 'hrsh7th/cmp-cmdline'
        use 'hrsh7th/cmp-git'
        use 'hrsh7th/cmp-calc'
        use 'hrsh7th/cmp-nvim-lsp-document-symbol'
        use { 'zbirenbaum/copilot-cmp', requires = { 'zbirenbaum/copilot.lua' } }

        -- Snippets
        use 'hrsh7th/cmp-vsnip'
        use 'hrsh7th/vim-vsnip'
        use 'rafamadriz/friendly-snippets'

        -- LSP & autocomplete UI
        use 'onsails/lspkind-nvim'
        use 'kosayoda/nvim-lightbulb'
        use 'weilbith/nvim-code-action-menu'
        -- use 'ray-x/lsp_signature.nvim'

        use 'lewis6991/gitsigns.nvim'

        use 'windwp/nvim-autopairs'

        -- Treesitter
        use 'nvim-treesitter/nvim-treesitter'
        use 'nvim-treesitter/playground'

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
