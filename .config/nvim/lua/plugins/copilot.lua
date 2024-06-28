return {
    "zbirenbaum/copilot.lua",
    dependencies = {
        "zbirenbaum/copilot-cmp",
        {
            "CopilotC-Nvim/CopilotChat.nvim",
            branch = "canary",
        },
    },
    config = function()
        require("copilot").setup({
            panel = { enabled = false },
            suggestion = { enabled = false, auto_trigger = true },
            copilot_node_command = "/usr/local/opt/node@20/bin/node",
            filetypes = {
                -- enable copilot for README files
                markdown = function()
                    if string.find(vim.fs.basename(vim.fn.expand('%')):upper(), "README") then
                        return true
                    end
                    return true
                end,
            }
        })
        require("CopilotChat").setup()

        if pcall(require, 'cmp') then
            local cmp = require('cmp')
            require("copilot_cmp").setup()
            vim.api.nvim_create_autocmd('BufEnter', {
                pattern = 'copilot-*',
                callback = function()
                    cmp.setup.buffer({
                        enabled = false,
                    })
                end
            })
        end
    end
}
