local commit_prompt = [[
Write commit message for the change. Keep the title under 50 characters and wrap message at 72 characters. Format as a gitcommit code block.
Title should be capitalized and written in imperative mood, completing the sentence "If applied, this commit will...".
Body should explain the what and why of the change, not the how.
]]

-- prompts.DOCUMENT = [[/COPILOT_GENERATE
-- Write documentation for the selected code. The reply should be a codeblock containing the original code with the
-- documentation added as comments. Use the most appropriate documentation style for the programming language used (e.g.
-- JSDoc for JavaScript, PHPDoc for PHP, google-style docstrings for Python etc.).
-- ]]

return {
    'zbirenbaum/copilot.lua',
    dependencies = {
        'zbirenbaum/copilot-cmp',
        {
            'CopilotC-Nvim/CopilotChat.nvim',
            version = '^4',
            build = 'make tiktoken',
        },
    },
    config = function()
        require('copilot').setup({
            panel = { enabled = false },
            suggestion = { enabled = false, auto_trigger = true },
            copilot_node_command = '/usr/local/opt/node@22/bin/node',
            filetypes = {
                -- enable copilot for README files
                markdown = function()
                    if string.find(vim.fs.basename(vim.fn.expand('%')):upper(), 'README') then
                        return true
                    end
                    return true
                end,
                yaml = true,
                json = true,
                helm = true,
            }
        })
        require('copilot_cmp').setup()

        local prompts = require('CopilotChat.config.prompts')
        prompts.Commit.prompt = commit_prompt

        require('CopilotChat').setup({
            headers = {
                user = '##   User',
                assistant = '##   Copilot',
                error = '##   Error',
                tool = '## 󱁤 Tool',
            },
            highlight_headers = false,
            separator = '━━',
            chat_autocomplete = true,
            mappings = {
                complete = {
                    insert = '',
                },
            },
            prompts = prompts,
            -- prompts = {
            --     Refactor = {
            --         prompt = 'Refactor the following code to improve its clarity and readability.'
            --     },
            --     BetterNamings = {
            --         prompt = 'Provide better names for the following variables and functions.'
            --     },
            --     Document = {
            --         prompt = prompts.DOCUMENT,
            --     },
            --     SwaggerApiDocs = {
            --         prompt = 'Provide documentation for the following API using Swagger.'
            --     },
            --     SwaggerJsDocs = {
            --         prompt = 'Write JSDoc for the following API using Swagger.'
            --     },
            --     Summarize = {
            --         prompt = 'Summarize the following text.'
            --     },
            --     Spelling = {
            --         prompt = 'Correct any grammar and spelling errors in the following text.'
            --     },
            --     Wording = {
            --         prompt = 'Improve the grammar and wording of the following text.'
            --     },
            --     Concise = {
            --         prompt = 'Rewrite the following text to make it more concise.'
            --     },
            --     TranslateRomanian = {
            --         prompt = 'Translate the following text to Romanian'
            --     },
            --     TranslateEnglish = {
            --         prompt = 'Translate the following text to English'
            --     },
            -- },
        })
    end
}
