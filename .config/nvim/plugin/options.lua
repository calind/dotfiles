-- Minimal configuration for Neovim
-- no plugins, no fancy stuff, just the basics

-- sanitize workflow
vim.opt.encoding = 'utf8'
vim.opt.wrap = false                         -- don't wrap lines
vim.opt.scrolloff = 3                        -- have some context around the current line always on screen
vim.opt.splitright = true                    -- split to the right by default
vim.opt.wildignore:append { '*.pyc', '*.o' } -- ignore some common extensions
vim.opt.updatetime = 50
vim.opt.timeout = true
vim.opt.timeoutlen = 100

-- set default <Tab> behavior: 4 spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- searching behavior
vim.opt.hlsearch = true   -- highlight matches
vim.opt.incsearch = true  -- incremental search
vim.opt.ignorecase = true -- searches are case insensitive...
vim.opt.smartcase = true  -- ...unless they contain at least one capital letter
vim.opt.showmatch = true  -- show matching
