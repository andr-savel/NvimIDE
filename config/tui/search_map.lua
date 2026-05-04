function NvimIdeHighlightGlobalSearchPattern(toSearch)
    vim.fn.setreg('/', toSearch)
    vim.opt.hlsearch = true
    vim.cmd('redraw')
end

function NvimIdeRemoveGlobalSearchPatternHighlight()
    vim.fn.setreg('/', "")
    vim.cmd('noh')
end

function NvimIdeGetCtrlOSpecialSymbolNoCond()
    return vim.api.nvim_replace_termcodes("<C-o>", true, false, true)
end

function NvimIdeGetCtrlOSpecialSymbol(mode)
    return (mode == "i" and NvimIdeGetCtrlOSpecialSymbolNoCond() or "")
end

function NvimIdeLocalSearch(mode, toSearch)
    NvimIdeHighlightGlobalSearchPattern(toSearch)
    -- TODO: to add 'expand("<cword>")' into search history only after non-null search

    vim.api.nvim_feedkeys(NvimIdeGetCtrlOSpecialSymbol(mode) .. "/", 'n', false)
end

-- Search in bufer
--     Call search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.keymap.set('n', '<C-F>', function() vim.cmd('noh'); NvimIdeLocalSearch("n", vim.fn.expand("<cword>")) end)
vim.keymap.set('i', '<C-F>', function() vim.cmd('noh'); NvimIdeLocalSearch("i", vim.fn.expand("<cword>")) end)
vim.keymap.set('s', '<C-F>', '<C-O>"ay <bar> :lua NvimIdeLocalSearch("s", vim.fn.getreg("a"))<CR>', {silent = true})

--     Continue search
-- TODO: nnoremap works incorrect: when cursor in (1,1) pos, then it dos not search (possibly stop after <Left> failure)
vim.keymap.set('n', '<f3>', '<Left>nzzgn<C-g>')
vim.keymap.set('i', '<f3>', '<Left><C-O>n<C-O>zz<C-O>gn<C-g>')
vim.keymap.set('s', '<f3>', '<Esc><f3>', {remap = true})
vim.keymap.set('c', '<f3>', '<CR>')

function NvimIdeFindFiles()
    local dir = vim.g.nvim_ide_start_dir
    if vim.g.nvim_ide_project_root then
        dir = vim.g.nvim_ide_project_root
    end

    require('fzf-lua').fzf_exec(vim.g.nvim_ide_fzf_source, {
        cwd = dir,
        prompt = "File> ",
        fzf_opts = {
            ['--history'] = NvimIdeGetProjectExtraFilesDir() .. '/fzf_search_files_history',
            ['--multi']   = true,
            ['--info']    = 'inline'
        },
        actions = {
            ["default"] = function(selected, opts)
                require('fzf-lua').actions.file_edit(selected, opts)
                vim.schedule(function()
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", true)
                end)
            end
        }
    })
end

vim.keymap.set('i', '<C-k>', '<C-o>:lua NvimIdeFindFiles()<CR>')
vim.keymap.set('n', '<C-k>', ':lua NvimIdeFindFiles()<CR>')

--     Call search
vim.keymap.set('n', '<M-f>', function() vim.opt.hlsearch = vim.fn.NvimIdeSearchInFilesContent("") end)
vim.keymap.set('i', '<M-f>', function() vim.opt.hlsearch = vim.fn.NvimIdeSearchInFilesContent("") end)
vim.keymap.set('s', '<M-f>', function() 
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-O>y", true, false, true), 'x', false)
    vim.opt.hlsearch = vim.fn.NvimIdeSearchInFilesContent(vim.fn.getreg())
end)

