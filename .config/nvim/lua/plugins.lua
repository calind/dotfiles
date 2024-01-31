local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

return require("lazy").setup({
        "calind/selenized.nvim",

        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "jay-babu/mason-null-ls.nvim",
        "b0o/schemastore.nvim",

        "tpope/vim-repeat",
        "tpope/vim-commentary",
        "tpope/vim-surround",
        "tpope/vim-unimpaired",

        "junegunn/vim-easy-align",

        "micarmst/vim-spellsync",

        "folke/which-key.nvim",

        "nvim-lua/plenary.nvim",

        "nvim-lualine/lualine.nvim",

        {
            "johmsalas/text-case.nvim",
            config = function()
                _G.textcase = require("textcase").api
            end
        },
        {
            "lambdalisue/suda.vim",
            config = function()
                vim.g.suda_smart_edit = 1
            end
        },

        -- LSP
        "neovim/nvim-lspconfig",
        "nvim-lua/lsp-status.nvim",
        "nvimtools/none-ls.nvim",

        -- Autocmplete
        {
            "hrsh7th/nvim-cmp",
            dependencies = {
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-cmdline",
                "hrsh7th/cmp-git",
                "hrsh7th/cmp-calc",
                "hrsh7th/cmp-nvim-lsp-document-symbol",

            }
        },
        -- { "zbirenbaum/copilot-cmp", dependencies = { "zbirenbaum/copilot.lua" } },

        -- Snippets
        -- "hrsh7th/cmp-vsnip",
        -- "hrsh7th/vim-vsnip",
        -- "rafamadriz/friendly-snippets",
        "dcampos/nvim-snippy",
        "dcampos/cmp-snippy",
        "honza/vim-snippets",


        -- LSP & autocomplete UI
        "onsails/lspkind-nvim",
        "kosayoda/nvim-lightbulb",
        "weilbith/nvim-code-action-menu",
        -- "ray-x/lsp_signature.nvim",

        "lewis6991/gitsigns.nvim",

        "windwp/nvim-autopairs",

        -- Treesitter
        "nvim-treesitter/nvim-treesitter",
        "nvim-treesitter/playground",
    },
    {
        ui = {
            border = heavy_border,
        }
    })
