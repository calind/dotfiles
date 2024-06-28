vim.b.lsp_goto_filter = function(name, opts)
    local sources = {}
    local stubs = {}

    for _, item in ipairs(opts.items) do
        local extension = vim.fn.fnamemodify(item.filename, ':e')
        if extension == 'pyi' then
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
