vim.b.lsp_goto_filter = function(name, opts)
    local sources = {}
    local stubs = {}

    for _, item in ipairs(opts.items) do
        if string.find(item.filename, 'stubs', 1, true) then
            table.insert(stubs, item)
        else
            table.insert(sources, item)
        end
    end

    if 'definition' == name and #sources >= 1 then
        opts.items = sources
    elseif 'declaration' == name and #stubs >= 1 then
        opts.items = stubs
    end

    return opts
end

vim.b.lsp_formatters = { 'html', 'null-ls' }
