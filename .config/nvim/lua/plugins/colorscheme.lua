return {
    {
        "calind/selenized.nvim", dev = true,
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme "selenized"
        end,
    },
}
