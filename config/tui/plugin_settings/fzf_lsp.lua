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
    local clients = vim.lsp.buf_get_clients(client_id or 0)

    local supported_client = false
    for _, client in pairs(clients) do
        supported_client = client.resolved_capabilities[feature]
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
local function fzf_wrap(name, opts, bang)
    name = name or ""
    opts = opts or {}
    bang = bang or 0

    local sink_fn = opts["sink*"] or opts["sink"]
    if sink_fn ~= nil then
        opts["sink"] = nil; opts["sink*"] = 0
    end
    local wrapped = fn["fzf#wrap"](name, opts, bang)
    wrapped["sink*"] = sink_fn

    return wrapped
end

local function fzf_run(...)
    return fn["fzf#run"](...)
end

local function common_sink(infile, lines)
    local locations = locations_from_lines(lines, not infile)
    if #lines > 1 then
        vim.fn.setqflist({}, ' ', {
            title = 'Language Server';
            items = locations;
        })
        api.nvim_command("copen")
        api.nvim_command("wincmd p")

        return
    end

    action = "e"

    for _, loc in ipairs(locations) do
        local edit_infile = (
            (infile or fn.expand("%:~:.") == loc["filename"]) and
            (action == "e" or action == "edit")
        )
        -- if i'm editing the same file i'm in, i can just move the cursor
        if not edit_infile then
            -- otherwise i can start executing the actions
            local err = api.nvim_command(action .. " " .. loc["filename"])
            if err ~= nil then
                api.nvim_command("echoerr " .. err)
            end
        end

        fn.cursor(loc["lnum"], loc["col"])
        api.nvim_command("normal! zvzz")
    end
end

local function fzf_locations(bang, prompt, source, infile)
    local options = {
        "--prompt", prompt .. "> ",
        "--multi",
        "--bind", g.nvim_ide_fzf_bind,
        "--history", fn.NvimIdeGetProjectExtraFilesDir() .. "/workspace_symbols_history"
    }

    fzf_run(fzf_wrap("fzf_lsp", {
        source = source,
        sink = partial(common_sink, infile),
        options = options,
    }, bang))
end

-- }}}

-- LSP reponse handlers {{{
local function workspace_symbol_handler(bang, err, result, ctx, _)
    if err ~= nil then
        perror(err)
        return
    end

    if not result or vim.tbl_isempty(result) then
        fn.NvimIdeEchoWarning("Workspace Symbol not found")
        return
    end

    local lines = lines_from_locations(
        vim.lsp.util.symbols_to_items(result, ctx.bufnr), true
    )
    fzf_locations(bang, "Workspace symbols", lines, false)
end

-- }}}

-- COMMANDS {{{
function nvim_ide_workspace_symbol(bang, q)
    if not check_capabilities("workspace_symbol") then
        return
    end

    local params = {query = q or ''}
    call_sync(
        "workspace/symbol", params, partial(workspace_symbol_handler, bang)
    )
end

-- }}}

