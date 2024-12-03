return {
    {
        'hoob3rt/lualine.nvim',
        config = function()
            local lualine = require('lualine')
            lualine.setup {
                options = {
                    section_separators = '',
                    component_separators = '❙',
                    globalstatus = true,
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = {
                        {
                            function()
                                local ok, lightbulb = pcall(require, 'nvim-lightbulb')
                                return ok and lightbulb.get_status_text() or ''
                            end,
                            separator = '',
                            padding = { left = 1, right = 0 },
                        },
                        {
                            'filename',
                            file_status = true,    -- Displays file status (readonly status, modified status)
                            newfile_status = true, -- Display new file status (new file means no write after created)
                            symbols = {
                                readonly = '[]',
                            },
                        },
                    },
                    lualine_c = {
                        'searchcount',
                    },
                    lualine_x = {
                        {
                            'diagnostics',
                            sources = { 'nvim_lsp' },
                            -- always_visible = true,
                            -- color = function(section) return { bg = colors.bg_2 } end
                        },
                        {
                            function() return vim.b.gitsigns_status or '' end
                        },
                        {
                            'fileformat',
                            symbols = {
                                unix = 'unix',
                                dos = 'dos',
                                mac = 'mac',
                            }
                        },
                        'encoding',
                        'filetype',
                        {
                            -- show the virtual environment name
                            function()
                                if (vim.env.VIRTUAL_ENV_PROMPT or '') ~= '' then
                                    return vim.env.VIRTUAL_ENV_PROMPT:gsub('%s+', '')
                                end

                                local venv = vim.fs.basename(vim.env.VIRTUAL_ENV or '')
                                if venv == '.venv' then
                                    venv = vim.fs.basename(vim.fs.dirname(vim.env.VIRTUAL_ENV or ''))
                                end
                                if venv ~= '' then
                                    return venv
                                end
                                return ''
                            end,
                        },
                    },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                },
            }
        end,
    }
}
