local wk = require('which-key')
local lsp = require('custom.lsp')
local gitsigns = require('gitsigns')

-- <CR> to clear search highlight
vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function()
        if vim.bo.buftype == '' then
            vim.keymap.set('n', '<CR>', ':nohlsearch<CR>',
                { silent = true, buffer = true, desc = 'Clear search highlight' })
        end
    end
})

-- dx strips trailing whitespace in normal mode
vim.keymap.set('n', 'dx', require('mini.trailspace').trim,
    { silent = true, desc = 'Remove trailing whitespace' })

vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move lines up' })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move lines down' })

vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous' })

-- greatest remap ever
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste over without yanking' })

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank to clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]], { desc = 'Delete into the void' })

-- the differences are so subtle that it's hard to tell them apart
vim.keymap.set('i', '<C-c>', '<Esc>')

vim.keymap.set('n', '<D-]>', vim.cmd.tabnext, { desc = 'Next tab' })
vim.keymap.set('n', '<D-[>', vim.cmd.tabprevious, { desc = 'Previous tab' })

vim.keymap.set('n', '<leader>t', vim.cmd.Inspect, { desc = 'Inspect' })
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Undo tree' })

-- Use upcoming LSP keymaps comming in 0.11.0
wk.register({ gr = { name = 'LSP' }, }, { mode = { 'n', 'v' } })
vim.keymap.set('n', 'grn', function() vim.lsp.buf.rename() end, { desc = 'vim.lsp.buf.rename()' })
vim.keymap.set({ 'n', 'x' }, 'gra', function() vim.lsp.buf.code_action() end, { desc = 'vim.lsp.buf.code_action()' })
vim.keymap.set('n', 'grr', function() vim.lsp.buf.references() end, { desc = 'vim.lsp.buf.references()' })
vim.keymap.set('i', '<C-S>', function() vim.lsp.buf.signature_help() end, { desc = 'vim.lsp.buf.signature_help()' })

wk.register({ ['<leader>g'] = { name = 'LSP go to' }, }, { mode = { 'n' } })
vim.keymap.set('n', '<leader>gd', lsp.buf.definition, { desc = 'vim.lsp.buf.definition()' })
vim.keymap.set('n', '<leader>gD', lsp.buf.declaration, { desc = 'vim.lsp.buf.declaration()' })
vim.keymap.set('n', '<leader>gi', lsp.buf.implementation, { desc = 'vim.lsp.buf.implementation()' })
vim.keymap.set('n', '<leader>gr', lsp.buf.references, { desc = 'vim.lsp.buf.references()' })
vim.keymap.set('n', '<leader>gT', lsp.buf.type_definition, { desc = 'vim.lsp.buf.type_definition()' })
vim.keymap.set('n', '<leader>f', function() lsp.buf.format() end, { desc = 'vim.lsp.buf.format()' })

-- Gitsigns
wk.register({ ['<leader>h'] = { name = 'Git [H]unks' } }, { mode = { 'n', 'v' } })
vim.keymap.set({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', { desc = 'Stage hunk' })
vim.keymap.set({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', { desc = 'Reset hunk' })
vim.keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'Undo staged hunk' })
vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Stage buffer' })
vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Reset buffer' })
vim.keymap.set('n', '<leader>hh', gitsigns.preview_hunk, { desc = 'Preview hunk' })
vim.keymap.set('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, { desc = 'Show git blame' })
vim.keymap.set('n', '<leader>hd', gitsigns.diffthis, { desc = 'Diff from index' })
vim.keymap.set('n', '<leader>hD', function() gitsigns.diffthis('~') end, { desc = 'Diff from HEAD~' })

-- Navigation
vim.keymap.set('n', ']c', function()
    if vim.wo.diff then return ']c' end
    vim.schedule(function() gitsigns.next_hunk() end)
    return '<Ignore>'
end, { expr = true, desc = 'Next change' })

vim.keymap.set('n', '[c', function()
    if vim.wo.diff then return '[c' end
    vim.schedule(function() gitsigns.prev_hunk() end)
    return '<Ignore>'
end, { expr = true, desc = 'Previous change' })

-- Copilot Chat
wk.register({ ['<leader>c'] = { name = 'Copilot' } }, { mode = { 'n', 'v' } })
vim.keymap.set({ 'n', 'v' }, '<leader>cc', vim.cmd.CopilotChat, { desc = 'Copilot Chat' })
vim.keymap.set({ 'n', 'v' }, '<leader>cr', vim.cmd.CopilotChatReview, { desc = 'Review selection' })
vim.keymap.set({ 'n', 'v' }, '<leader>ce', vim.cmd.CopilotChatExplain, { desc = 'Explain selection' })
vim.keymap.set({ 'n', 'v' }, '<leader>cf', vim.cmd.CopilotChatFixDiagnostic, { desc = 'Fix diagnostics' })
vim.keymap.set({ 'n', 'v' }, '<leader>cF', vim.cmd.CopilotChatFix, { desc = 'Fix the code!' })
vim.keymap.set({ 'n', 'v' }, '<leader>cR', vim.cmd.CopilotChatFix, { desc = 'Refactor' })
vim.keymap.set({ 'n', 'v' }, '<leader>cq',
    function()
        local selection = require('CopilotChat.select').visual
        if vim.api.nvim_get_mode().mode == 'n' then
            selection = require('CopilotChat.select').buffer
        end

        local input = vim.fn.input('Quick Chat: ')
        if input ~= '' then
            require('CopilotChat').ask(input, { selection = selection })
        end
    end,
    { desc = 'Copilot Quick Chat' }
)
vim.keymap.set({ 'n', 'v' }, '<leader>ca',
    function()
        local selection = require('CopilotChat.select').visual
        if vim.api.nvim_get_mode().mode == 'n' then
            selection = require('CopilotChat.select').buffer
        end

        local actions = require('CopilotChat.actions')
        actions.pick(actions.prompt_actions({ selection = selection }))
    end,
    { desc = 'Copilot actions' }
)

vim.keymap.set({ 'n' }, '<leader>cQ',
    function()
        local selection = function(source)
            local gitdiff = require('CopilotChat.select').gitdiff
            local result = gitdiff(source)
            vim.print(vim.inspect(result))
            return result
        end

        local input = vim.fn.input('Quick Chat (gitdiff): ')
        if input ~= '' then
            require('CopilotChat').ask(input, { selection = selection })
        end
    end,
    { desc = 'Copilot Quick Chat with git diff' }
)

vim.keymap.set('n', '<leader>cd', function()
    local chat = require('CopilotChat')
    local select_textobject = require('nvim-treesitter.textobjects.select').select_textobject

    select_textobject('@function.outer')
    chat.ask('/Document', { selection = require('CopilotChat.select').visual })
end, { desc = 'Comment the current function' })

-- Toggle options
wk.register({ ['<leader>o'] = { name = 'T[o]ggle' } })
vim.keymap.set('n', '<leader>od',
    function()
        vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    end,
    { desc = 'diagnostics' }
)
vim.keymap.set('n', '<leader>oD', gitsigns.toggle_deleted, { desc = 'git deleted' })
vim.keymap.set('n', '<leader>oB', gitsigns.toggle_current_line_blame, { desc = 'git blame' })

-- Text object
vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'hunk' })
