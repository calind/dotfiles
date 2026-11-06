local helpers = require('null-ls.helpers')
local methods = require('null-ls.methods')

return helpers.make_builtin({
    name = 'dockerfmt',
    method = methods.internal.FORMATTING,
    filetypes = { 'dockerfile' },
    generator_opts = {
        command = 'dockerfmt',
        to_stdin = true,
    },
    factory = helpers.formatter_factory,
})
