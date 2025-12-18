local Spinner = require('CopilotChat.ui.spinner')
vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('gitcommit-copilotchat', { clear = true }),
    pattern = 'COMMIT_EDITMSG',
    once = true,
    callback = function()
        local chat = require('CopilotChat')
        local buf = vim.api.nvim_get_current_buf()
        local spinner = Spinner(buf)

        -- local ns = vim.api.nvim_create_namespace('gitcommit-copilotchat-loader')
        -- vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
        --     virt_text = { { 'Generating commit message...', 'CopilotChatStatus' } },
        --     virt_text_pos = 'eol',
        -- })
        spinner:start('Generating commit message...')

        local config = vim.tbl_deep_extend('force', require('CopilotChat.config.prompts').Commit, {
            model = 'gpt-4.1',
            headless = true,
            callback = function(response)
                -- Extract content between first code block markers
                local content = response.content or ''
                local commit_msg = content:match('```[%w]*\n(.-)\n?```')
                local lines
                if commit_msg then
                    lines = vim.split(commit_msg, '\n', { plain = true })
                else
                    lines = { '# Error: Unable to generate commit', '#' }
                    for _, line in ipairs(vim.split(response, '\n', { plain = true })) do
                        table.insert(lines, '# ' .. line)
                    end
                end
                -- vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
                spinner:finish()
                vim.api.nvim_buf_set_lines(buf, 0, 0, false, lines)
                return response
            end,
        })
        chat.ask(config.prompt, config)
    end,
})
