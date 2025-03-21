local prompts = {}

prompts.DOCUMENT = [[/COPILOT_GENERATE
Write documentation for the selected code. The reply should be a codeblock containing the original code with the
documentation added as comments. Use the most appropriate documentation style for the programming language used (e.g.
JSDoc for JavaScript, PHPDoc for PHP, google-style docstrings for Python etc.).
]]

return {
    'zbirenbaum/copilot.lua',
    dependencies = {
        'zbirenbaum/copilot-cmp',
        {
            'CopilotC-Nvim/CopilotChat.nvim',
            version = '^3',
            build = 'make tiktoken',
        },
    },
    config = function()
        require('copilot').setup({
            panel = { enabled = false },
            suggestion = { enabled = false, auto_trigger = true },
            copilot_node_command = '/usr/local/opt/node@20/bin/node',
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

        require('CopilotChat').setup({
            question_header = '   User ',
            answer_header = '   Copilot ',
            error_header = '   Error ',
            chat_autocomplete = true,
            mappings = {
                complete = {
                    insert = '',
                },
            },
            prompts = {
                Refactor = {
                    prompt = 'Refactor the following code to improve its clarity and readability.'
                },
                BetterNamings = {
                    prompt = 'Provide better names for the following variables and functions.'
                },
                Document = {
                    prompt = prompts.DOCUMENT,
                },
                SwaggerApiDocs = {
                    prompt = 'Provide documentation for the following API using Swagger.'
                },
                SwaggerJsDocs = {
                    prompt = 'Write JSDoc for the following API using Swagger.'
                },
                Summarize = {
                    prompt = 'Summarize the following text.'
                },
                Spelling = {
                    prompt = 'Correct any grammar and spelling errors in the following text.'
                },
                Wording = {
                    prompt = 'Improve the grammar and wording of the following text.'
                },
                Concise = {
                    prompt = 'Rewrite the following text to make it more concise.'
                },
                TranslateRomanian = {
                    prompt = 'Translate the following text to Romanian'
                },
                TranslateEnglish = {
                    prompt = 'Translate the following text to English'
                },
            },
        })
    end
}
