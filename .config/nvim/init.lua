--[[
-- Setup initial configuration,
--
-- Primarily just download and execute lazy.nvim
--]]

-- Setup Leader key
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Setup UI
local ui = require('custom.ui')
ui.setup()

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    }
end

-- Add lazy to the `runtimepath`, this allows us to `require` it.
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Set up lazy, and load my `lua/custom/plugins/` folder
require('lazy').setup({ import = 'plugins' }, {
    change_detection = {
        notify = false,
    },
    ui = {
        border = ui.border,
        backdrop = 100,
    },
    dev = {
        path = '~/work/src/github.com/calind',
    },
})
