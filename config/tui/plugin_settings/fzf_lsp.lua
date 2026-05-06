local vim, fn, api, g = vim, vim.fn, vim.api, vim.g

-- utility functions {{{
local function partial(func, arg)
    return (function(...)
        return func(arg, ...)
    end)
end

local function perror(err)
    print("ERROR: " .. tostring(err))
end

-- }}}

-- LSP utility {{{
local function extract_result(results_lsp)
    if results_lsp then
        local results = {}
        for client_id, response in pairs(results_lsp) do
            if response.result then
                for _, result in pairs(response.result) do
                    result.client_id = client_id
                    table.insert(results, result)
                end
            end
        end

        return results
    end
end

local function call_sync(method, params, handler)
    params = params or {}
    local bufnr = vim.api.nvim_get_current_buf()
    timeoutMs = 5000
    local results_lsp, err = vim.lsp.buf_request_sync(
        bufnr, method, params, timeoutMs
    )

    local ctx = {
        method = method,
        bufnr = bufnr,
        client_id = results_lsp and next(results_lsp) or nil,
    }
    handler(err, extract_result(results_lsp), ctx, nil)
end

local function check_capabilities(feature, client_id)
    local clients = vim.lsp.get_clients({id = client_id, bufnr = 0})

    local supported_client = false
    for _, client in pairs(clients) do
        supported_client = client.server_capabilities[feature]
        if supported_client then goto continue end
    end

    ::continue::
    if supported_client then
        return true
    else
        if #clients == 0 then
            print("LSP: no client attached")
        else
            print("LSP: server does not support " .. feature)
        end
        return false
    end
end

local function lines_from_locations(locations, include_filename)
    local fnamemodify = (function (filename)
        if include_filename then
            return fn.fnamemodify(filename, ":~:.") .. ":"
        else
            return ""
        end
    end)

    local lines = {}
    for _, loc in ipairs(locations) do
        table.insert(lines, (
            fnamemodify(loc['filename'])
            .. loc["lnum"]
            .. ":"
            .. loc["col"]
            .. ": "
            .. vim.trim(loc["text"])
        ))
    end

    return lines
end

local function locations_from_lines(lines, filename_included)
    local extract_location = (function (l)
        local path, lnum, col, text, bufnr

        if filename_included then
            path, lnum, col, text = l:match("([^:]*):([^:]*):([^:]*):(.*)")
        else
            bufnr = api.nvim_get_current_buf()
            path = fn.expand("%")
            lnum, col, text = l:match("([^:]*):([^:]*):(.*)")
        end

        return {
            bufnr = bufnr,
            filename = path,
            lnum = lnum,
            col = col,
            text = text or "",
        }
    end)

    local locations = {}
    for _, l in ipairs(lines) do
        table.insert(locations, extract_location(l))
    end

    return locations
end

-- }}}

-- FZF functions {{{

local function handle_selected_in_fzf(selected, infile)
    local lines = {}
    for _, item in ipairs(selected) do
        if type(item) == "table" and item.text then
            lines[#lines + 1] = item.text
        elseif type(item) == "string" then
            lines[#lines + 1] = item
        end
    end

    local locations = locations_from_lines(lines, not infile)
    if #lines > 1 then
        vim.fn.setqflist({}, ' ', {
            title = 'Language Server';
            items = locations;
        })
        vim.api.nvim_command("copen")
        vim.api.nvim_command("wincmd p")
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", true)
        return
    end

    local action = "e"
    for _, loc in ipairs(locations) do
        local edit_infile = (
            (infile or vim.fn.expand("%:~:.") == loc["filename"]) and
            (action == "e" or action == "edit")
        )
        if not edit_infile then
            local err = vim.api.nvim_command(action .. " " .. loc["filename"])
            if err ~= nil then
                vim.api.nvim_command("echoerr " .. err)
            end
        end
        vim.fn.cursor(loc["lnum"], loc["col"])
        vim.api.nvim_command("normal! zvzz")
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", true)
end

local function fzf_locations(prompt, source, infile)
    require('fzf-lua').fzf_exec(source, {
        prompt = prompt .. "> ",
        multi = true,
        fullscreen = false,
        fzf_opts = {
            ['--multi'] = '',
            ['--info'] = 'inline',
            ['--history'] = NvimIdeGetProjectExtraFilesDir() .. "/workspace_symbols_history",
        },
        actions = {
            ['default'] = function(selected)
                handle_selected_in_fzf(selected, infile)
            end
        },
    })
end

-- }}}

-- LSP reponse handlers {{{
local function workspace_symbol_handler(bang, err, result, ctx, _)
    if err ~= nil then
        perror(err)
        return
    end

    if not result or vim.tbl_isempty(result) then
        NvimIdeEchoWarning("Workspace Symbol not found")
        return
    end

    local lines = lines_from_locations(
        vim.lsp.util.symbols_to_items(result, ctx.bufnr), true
    )
    fzf_locations("Workspace symbols", lines, false)
end

-- }}}

-- COMMANDS {{{
function nvim_ide_workspace_symbol(bang, q)
    if not check_capabilities("workspaceSymbolProvider") then
        return
    end

    local params = {query = q or ''}
    call_sync(
        "workspace/symbol", params, partial(workspace_symbol_handler, bang)
    )
end

-- }}}

