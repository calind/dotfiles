local _M = { buf = {} }

local filtered_goto = function(name)
    return function()
        local callback = vim.lsp.buf[name]
        local filter = vim.b.lsp_goto_filter
        if filter then
            callback({
                on_list = function(opts)
                    local filtered_opts = filter(name, opts)
                    vim.fn.setqflist({}, ' ', filtered_opts)
                    if #filtered_opts.items > 1 then
                        vim.cmd.copen()
                    else
                        vim.cmd.cfirst()
                    end
                end
            })
        else
            callback()
        end
    end
end

local format_filter = function(client)
    local formatters = vim.b.lsp_formatters or {}
    if vim.tbl_isempty(formatters) or vim.tbl_contains(formatters, client.name) then
        return true
    end
    return false
end

function _M.buf.format(_opts)
    local opts = _opts or {}
    opts.filter = opts.filter or format_filter
    vim.lsp.buf.format(opts)
end

_M.buf.definition = filtered_goto('definition')
_M.buf.declaration = filtered_goto('declaration')
_M.buf.implementation = filtered_goto('implementation')
_M.buf.references = filtered_goto('references')
_M.buf.type_definition = filtered_goto('type_definition')

return _M
