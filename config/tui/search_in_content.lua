-- Search in files content using ripgrep.
-- Main feature -- search by files on disk and modified files in vim in the same time (like search in files in IDEs).

-- Tmp files suffix
local nvim_ide_tmp_files_suffix = "_nvim_ide_tmp"

-- Special script for searhing by file content
local function GetGrepScriptPath()
    return NvimIdeGetProjectExtraFilesDir() .. '/search_in_content_grep'
end

function NvimIdeGetAliveBuffersOutput()
    return vim.fn.execute('silent! buffers')
end

function NvimIdeGetChangedBufferIds()
    local changedBuffers = {}
    local buffers = vim.fn.getbufinfo({bufloaded = 1})
    for _, buf in ipairs(buffers) do
        if buf.changed == 1 then
            table.insert(changedBuffers, buf.bufnr)
        end
    end
    return changedBuffers
end

local function GetStartIdx()
    local startIdx = #vim.g.nvim_ide_real_project_root
    if vim.g.nvim_ide_real_project_root:sub(startIdx, startIdx) ~= '/' then
        startIdx = startIdx + 1
    end
    return startIdx
end

local function ContainsRootPath(fullPath)
    return fullPath:find(vim.g.nvim_ide_real_project_root, 1, true) ~= nil
end

function NvimIdeGetBuffersRelativePaths(bIds)
    local out = {}
    local startIdx = GetStartIdx()
    for _, bi in ipairs(bIds) do
        local fullPath = vim.fn.expand('#' .. bi .. ':p')
        if ContainsRootPath(fullPath) then
            table.insert(out, fullPath:sub(startIdx + 1))
        end
    end
    return out
end

function NvimIdeGetRipgrepExclusionString(changedBufs)
    local modifiedFiles = NvimIdeGetBuffersRelativePaths(changedBufs)
    local out = ""
    for _, bn in ipairs(modifiedFiles) do
        out = out .. ' -g \\!' .. bn
    end
    return out
end

function NvimIdeSaveToTmps(changedBufs)
    local out = {}
    if #changedBufs == 0 then
        return out
    end
    local currBuf = vim.fn.bufnr()
    for _, bi in ipairs(changedBufs) do
        local bufFilePath = vim.fn.expand('#' .. bi .. ':p')
        if #bufFilePath == 0 then
            goto continue
        end
        local tmpF = bufFilePath .. nvim_ide_tmp_files_suffix
        vim.cmd('silent b' .. bi .. '|w! ' .. tmpF)
        table.insert(out, tmpF)
        ::continue::
    end
    vim.cmd('silent b' .. currBuf)
    return out
end

function NvimIdeEchoWarning(msg)
    vim.cmd('redraw')
    vim.cmd('echohl WarningMsg')
    vim.cmd('echo "' .. msg:gsub('"', '\\"') .. '"')
    vim.cmd('echohl None')
end

local function HandleQuickfixSearchResult(ptrn)
    -- Open quickfix if not empty and run postprocessing
    local qflist = vim.fn.getqflist()
    if #qflist > 0 then
        vim.cmd('copen')
        NvimIdeQuickfixPostprocess(ptrn)
        NvimIdeHighlightGlobalSearchPattern(ptrn)
        return 1
    end
    return 0
end

-- Search completion marker – helps distinguish a completed empty search
local search_completion_marker = "        \27[1;34m \u{2584}\u{2584}\u{2584}\u{2584}\u{2584}\u{2584}\u{2584}\u{2584}\u{2584}\u{2584}\u{2584}\u{2584}\u{2584}\u{2584}\u{2584}  \27[0m"

function NvimIdeGenGrepScript(changedBufs, savedTmps, rgExtraArgs)
    -- Generate the helper bash script that combines disk search and modified buffers search
    local basicSearcher = vim.g.nvim_ide_content_search_rg_basic_cmd .. ' ' .. rgExtraArgs
    local scriptContent = {}
    table.insert(scriptContent, '#!/bin/bash')
    table.insert(scriptContent, "")

    if #savedTmps > 0 then
        local startIdx = GetStartIdx()
        local strTmps = ""
        for _, i in ipairs(savedTmps) do
            if ContainsRootPath(i) then
                strTmps = strTmps .. " " .. i:sub(startIdx + 1)  -- relative path
            end
        end
        table.insert(scriptContent, basicSearcher .. ' "$1" ' .. strTmps .. ' | sed -e s/' .. nvim_ide_tmp_files_suffix .. '//g')
        table.insert(scriptContent, 'rm ' .. strTmps)
    end

    table.insert(scriptContent, "")
    table.insert(scriptContent, basicSearcher .. ' ' .. NvimIdeGetRipgrepExclusionString(changedBufs) .. ' "$1" ')
    table.insert(scriptContent, "")
    -- search_completion_marker helps to distinguish long search from completed empty search
    table.insert(scriptContent, 'echo "' .. search_completion_marker .. '"')
    table.insert(scriptContent, "exit 0")

    local scriptPath = GetGrepScriptPath()
    vim.fn.writefile(scriptContent, scriptPath)
    vim.fn.system('chmod +x ' .. vim.fn.shellescape(scriptPath))
end

local function rg_to_qf(line)
    -- Parse a ripgrep output line into a quickfix list item
    local parts = { line:match('(.-)%s*:%s*(%d+)%s*:%s*(%d+)%s*:(.*)') }
    if not parts[1] then
        parts = { line:match('(.-)%s*:%s*(%d+)%s*:(.*)') }
        if parts then
            -- no column match
            table.insert(parts, 2, nil) -- insert nil for column position
        end
    end
    if not parts then
        return nil
    end
    local filename = parts[1]
    if not vim.o.acd then
        filename = vim.fn.fnamemodify(filename, ':p')
    end
    local dict = { filename = filename, lnum = tonumber(parts[2]), text = parts[4] or '' }
    if parts[3] then
        dict.col = tonumber(parts[3])
    end
    return dict
end

function NvimIdeSearchInFilesContent(extPtrn)
    -- Main search function: highlight if external pattern given, prompt for search term,
    -- search both on-disk and modified buffers using fzf-lua
    local hasExtPtrn = #extPtrn > 0
    if hasExtPtrn then
        NvimIdeHighlightGlobalSearchPattern(extPtrn)
    end

    local null_input_word = '___nvim_ide_null_input___'
    local toSearch = vim.fn.input({ prompt = 'Project search: ', cancelreturn = null_input_word })
    if toSearch == null_input_word then
        if hasExtPtrn then
            NvimIdeRemoveGlobalSearchPatternHighlight()
        end
        return false
    end

    if #toSearch == 0 then
        if hasExtPtrn then
            toSearch = extPtrn
            vim.fn.histadd('input', toSearch)
        end
    end

    if #toSearch == 0 then
        toSearch = vim.fn.expand('<cword>')
        vim.fn.histadd('input', toSearch)
    end

    if #toSearch == 0 then
        if hasExtPtrn then
            NvimIdeRemoveGlobalSearchPatternHighlight()
        end
        NvimIdeEchoWarning('Empty search pattern')
        return false
    end

    NvimIdeRemoveGlobalSearchPatternHighlight()
    NvimIdeClearAndCloseQuickfix()

    local changedBuffers = NvimIdeGetChangedBufferIds()
    local savedTmps = NvimIdeSaveToTmps(changedBuffers)
    NvimIdeGenGrepScript(changedBuffers, savedTmps, '--color=always')
    local searcher = GetGrepScriptPath()

    local cmdToSearch = searcher .. ' ' .. vim.fn.shellescape(vim.fn.escape(toSearch, '()'))

    require('fzf-lua').fzf_exec(cmdToSearch, {
        cwd = vim.g.nvim_ide_real_project_root,
        fzf_opts = {
            ['--prompt'] = 'Project search> ',
            ['--multi'] = '',
            ['--history'] = NvimIdeGetProjectExtraFilesDir() .. '/fzf_search_in_content_history',
            ['--info'] = 'inline',
            ['--ansi'] = ''
        },
        actions = {
            ['default'] = function(selected)
                -- selected is a table of strings (lines chosen by the user)
                local list = {}
                for _, l in ipairs(selected) do
                    local _, blockcount = l:gsub("▄", "")
                    if blockcount ~= 15 then
                        local qf_item = rg_to_qf(l)
                        if qf_item then
                            table.insert(list, qf_item)
                        end
                    end
                end

                if #list == 1 then
                    local item = list[1]
                    local target_bufnr = vim.fn.bufnr(item.filename)   -- 0 or buffer number

                    if target_bufnr > 0 and vim.fn.bufloaded(target_bufnr) == 1 then
                        vim.cmd('buffer ' .. target_bufnr)
                    else
                        vim.cmd('e ' .. item.filename)
                    end

                    vim.fn.cursor(item.lnum, item.col or 1)
                    NvimIdeCenterText()
                    NvimIdeHighlightGlobalSearchPattern(toSearch)
                else
                    vim.fn.setqflist({}, 'r', {title = cmdToSearch, items = list})
                    HandleQuickfixSearchResult(toSearch)
                end
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", true)
            end
        },
    })

    return true
end

