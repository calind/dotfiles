local ui = require('custom.ui')
local listchars = vim.deepcopy(ui.listchars)
listchars['tab'] = '  '
vim.b.listchars = listchars
vim.b.lsp_formatters = { 'templ' }
