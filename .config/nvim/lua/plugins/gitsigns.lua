local ui = require('custom.ui')

return {
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add          = { text = '┃', },
                change       = { text = '┃', },
                delete       = { text = '┃', },
                topdelete    = { text = '┃', },
                changedelete = { text = '┃', },
            },
            sign_priority = 1,
            attach_to_untracked = false,
            preview_config = {
                -- Options passed to nvim_open_win
                border = ui.border,
            },
            current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
            worktrees = {
                {
                    toplevel = vim.env.HOME,
                    gitdir = vim.env.HOME .. '/.dotfiles.git'
                },
            },
        },
    },
}
