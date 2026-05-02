local opts = {remap = true, silent = true}
local silent_opts = {silent = true}

-- To change current directory automatically according to opened file in current window
vim.opt.autochdir = true

-- Update time (used in LSP symbol highlight)
vim.opt.updatetime = 300

-- Comment/Uncomment block of code
vim.keymap.set('i', '<C-/>', '<C-o>gcc', opts)

--vim.keymap.set('v', '<C-/>', 'gc', opts)
function toggle_comment_and_insert()
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gc", true, false, true), "x", false)
    vim.api.nvim_feedkeys("i", "n", false)
    vim.api.nvim_win_set_cursor(0, cursor)
end
vim.keymap.set('x', '<C-/>', toggle_comment_and_insert, silent_opts)
vim.keymap.set('s', '<C-/>', "<C-g><cmd>lua toggle_comment_and_insert()<CR>", silent_opts)

-- Switch windows
vim.keymap.set('', '<C-w>', '<C-w>w', {nowait = true})
vim.keymap.set('i', '<C-w>', '<C-O><C-w>w')
vim.keymap.set('s', '<C-w>', '<Esc><C-w>w')
vim.keymap.set('c', '<C-w>', '<C-O><C-w>w')
vim.keymap.set('o', '<C-w>', '<C-O><C-w>w')
--     in 'terminal' mode
vim.keymap.set('t', '<C-w>', [[<C-\><C-N><C-w>wi]])

-- New tab
vim.keymap.set('', '<C-t>', ':tab sb<CR>', silent_opts)
vim.keymap.set('i', '<C-t>', '<C-O>:tab sb<CR>', silent_opts)
vim.keymap.set('t', '<C-t>', [[<C-\><C-N>:tab sb<CR>]], silent_opts)

-- Switch tabs
vim.keymap.set('', '<C-PageUp>', ':tabprev<CR>', silent_opts)
vim.keymap.set('i', '<C-PageUp>', '<C-O>:tabprev<CR>', silent_opts)
vim.keymap.set('s', '<C-PageUp>', '<Esc>:tabprev<CR>', silent_opts)
vim.keymap.set('o', '<C-PageUp>', '<C-O>:tabprev<CR>', silent_opts)
--     in 'terminal' mode
vim.keymap.set('t', '<C-PageUp>', [[<C-\><C-N>:tabprev<CR>i]], silent_opts)

vim.keymap.set('', '<C-PageDown>', ':tabnext<CR>', silent_opts)
vim.keymap.set('i', '<C-PageDown>', '<C-O>:tabnext<CR>', silent_opts)
vim.keymap.set('s', '<C-PageDown>', '<Esc>:tabnext<CR>', silent_opts)
vim.keymap.set('o', '<C-PageDown>', '<C-O>:tabnext<CR>', silent_opts)
--     in 'terminal' mode
vim.keymap.set('t', '<C-PageDown>', [[<C-\><C-N>:tabnext<CR>i]], silent_opts)

-- Close tab (like finish shell session in teminal)
vim.keymap.set('', '<C-d>', ':tabclose<CR>')
vim.keymap.set('i', '<C-d>', '<C-O>:tabclose<CR>')

-- Close window without closing buffer
-- TODO: do not close window when it is last window in tab
vim.keymap.set('n', '<M-c>', '<C-w>c')
vim.keymap.set('i', '<M-c>', '<C-O><C-w>c')
vim.keymap.set('c', '<M-c>', '<C-O><C-w>c')
vim.keymap.set('o', '<M-c>', '<C-O><C-w>c')
--     in 'terminal' mode
vim.keymap.set('t', '<M-c>', [[<C-\><C-N><C-w>c]])

local function IsCurrBufQuickFix()
    return vim.bo.filetype == 'qf'
end

local function is_curr_window_quick_fix()
    return vim.w.quickfix_title ~= nil
end

local function GetBufferList()
    local current = vim.api.nvim_get_current_buf()
    local alternate = vim.fn.bufnr('#')
    return GetBufferListImpl(current, alternate)
end

-- Close buffer without closing window
-- Do not switch to 'QuickFix' buffer on it's existence
function NvimIdeCloseCurrBuf()
    if is_curr_window_quick_fix() then
        NvimIdeClearAndCloseQuickfix()
        return
    end

    local mru_bufs = GetBufferList()

    if #mru_bufs < 2 then
        error("NvimIde: failed to close the only file buffer")
    end

    if vim.bo.modified then
        error("NvimIde: failed to close modified buffer")
    end

    vim.cmd('silent b' .. mru_bufs[2].id)
    vim.cmd('bd ' .. mru_bufs[1].id)
end

vim.keymap.set('n', '<M-x>', ':lua NvimIdeCloseCurrBuf()<CR>', silent_opts)
vim.keymap.set('i', '<M-x>', '<C-O>:lua NvimIdeCloseCurrBuf()<CR>', silent_opts)

-- Code window markers
local function NvimIdeMarkCodeWindow()
    vim.w.nvim_ide_is_code_window = true
end

function NvimIdeIsCodeWindow()
    return vim.w.nvim_ide_is_code_window or false
end

local group = vim.api.nvim_create_augroup("NvimIdeTabNewGroup", {clear = true})
vim.api.nvim_create_autocmd("TabNew", {
    group = group,
    callback = function()
        NvimIdeMarkCodeWindow()
    end,
})

-- this function should be called on startup to mark initial window as 'code' window
NvimIdeMarkCodeWindow()

local function mark_and_split(cmd, terminal_mode)
    vim.cmd(cmd)
    NvimIdeMarkCodeWindow()
    vim.cmd('wincmd w')

    if terminal_mode then
        vim.cmd('startinsert')
    end
end

-- Split window vertically
vim.keymap.set('n', '<M-\\>', function() mark_and_split('vsplit') end, silent_opts)
vim.keymap.set('i', '<M-\\>', function() mark_and_split('vsplit') end, silent_opts)
vim.keymap.set('t', '<M-\\>', function() mark_and_split('vsplit', true) end, silent_opts)

-- Split windows horizontally
vim.keymap.set('n', '<M-->', function() mark_and_split('split') end, silent_opts)
vim.keymap.set('i', '<M-->', function() mark_and_split('split') end, silent_opts)
vim.keymap.set('t', '<M-->', function() mark_and_split('split', true) end, silent_opts)

function GetBufferListImpl(current, alternate)
    local bufs = vim.api.nvim_list_bufs()
    local valid_bufs = {}

    for _, bufnr in ipairs(bufs) do
        local b = vim.bo[bufnr]
        if b.buflisted and (b.buftype == "" or b.buftype == "terminal") then
            local info = vim.fn.getbufinfo(bufnr)[1]
            table.insert(valid_bufs, {
                id = bufnr,
                lastused = info.lastused,
                priority = (bufnr == current and 1) or (bufnr == alternate and 2) or 3
            })
        end
    end

    table.sort(valid_bufs, function(a, b)
        if a.priority ~= b.priority then return a.priority < b.priority end
        return a.lastused > b.lastused
    end)

    return valid_bufs
end

local function get_buffer_entries(project_root, current, alternate)
    local valid_bufs = GetBufferListImpl(current, alternate)

    local bufn_color = "\27[38;2;211;134;155m"  -- use gcolor3 util to get color from screen
    local percent_color = "\27[38;2;227;103;96m"
    local sharp_color = "\27[38;2;216;166;87m"
    local color_reset = "\27[0m"

    local entries = {}
    for _, item in ipairs(valid_bufs) do
        local bufnr = item.id
        local flag = " "
        if bufnr == current then
            flag = percent_color .. "%" .. color_reset
        elseif bufnr == alternate then
            flag = sharp_color .. "#" .. color_reset
        end

        local full_path = vim.api.nvim_buf_get_name(bufnr)

        local rel_path = full_path
        if full_path:sub(1, #project_root) == project_root then
            rel_path = full_path:sub(#project_root + 2)
        end

        if rel_path == "" then rel_path = " (root) " end
        if full_path == "" then rel_path = "[No Name]" end

        local entry = string.format("[%d]\t[%s%d%s] %s\t%s",
            bufnr,
            bufn_color, bufnr, color_reset,
            flag,
            rel_path)

        table.insert(entries, entry)
    end

    return entries
end

local function ShowFzfBuffers()
    local project_root = vim.g.nvim_ide_real_project_root or vim.fn.getcwd()
    local current = vim.api.nvim_get_current_buf()
    local alternate = vim.fn.bufnr('#')

    require('fzf-lua').fzf_exec(
        function(cb)
            local entries = get_buffer_entries(project_root, current, alternate)
            for _, e in ipairs(entries) do cb(e) end
            cb(nil)
        end,
        {
            prompt = 'Buffers> ',
            cwd = project_root,
            fzf_opts = {
                ['+m']             = '',
                ['-x']             = '',
                ['--tiebreak']     = 'index',
                ['--header-lines'] = '1',
                ['--ansi']         = '',
                ['--delimiter']    = '\t',
                ['--with-nth']     = '2..',
                ['-n']             = '2,1..2',
                ['--info']         = 'inline',
                ['--history']      = NvimIdeGetProjectExtraFilesDir() .. '/fzf_buffers_history',
            },
            actions = {
                ['default'] = function(selected)
                    if not selected or #selected == 0 then return end

                    local selection = selected[1] 
                    local bufnr_str = selection:match("^%[(%d+)%]")
                    local bufnr = tonumber(bufnr_str)

                    if bufnr then
                        vim.api.nvim_set_current_buf(bufnr)                    
                        vim.schedule(function()
                            if vim.bo[bufnr].buftype == "terminal" then
                                vim.cmd("startinsert")
                            else
                                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", true)
                            end
                        end)
                    end
                end,
                ['alt-x'] = {
                    fn = function(selected)
                        local bufnr = tonumber(selected[1]:match("^%[(%d+)%]"))
                        if bufnr then
                            if vim.bo[bufnr].buftype == "terminal" then
                                vim.api.nvim_buf_delete(bufnr, {force = true})
                                vim.cmd("stopinsert")
                            else
                                vim.api.nvim_buf_delete(bufnr, {force = false})
                            end
                        end
                    end,
                    reload = true -- fzf-lua заново вызовет анонимную функцию-источник
                }
            }
        }
    )
end

local function GotoCodeWindow()
    if NvimIdeIsCodeWindow() then
        return true
    end

    local initial_win = vim.fn.win_getid()
    local code_win = -1

    while true do
        vim.cmd('wincmd w')
        local curr_win = vim.fn.win_getid()

        if NvimIdeIsCodeWindow() then
            if code_win == -1 then
                code_win = curr_win
            else
                vim.fn.NvimIdeEchoWarning("More than 1 code window. Switch to code window manually and choose the buffer.")
                vim.fn.win_gotoid(initial_win)
                return false
            end
        end

        if curr_win == initial_win then
            break
        end
    end

    if code_win == -1 then
        vim.fn.NvimIdeEchoWarning("No code window(s).")
        vim.fn.win_gotoid(initial_win)
        return false
    end

    vim.fn.win_gotoid(code_win)
    return true
end

function NvimIdeBuffers()
    if not GotoCodeWindow() then
        return
    end

    local effective_root = vim.g.nvim_ide_start_dir
    if vim.g.nvim_ide_project_root ~= nil then
        effective_root = vim.g.nvim_ide_project_root
    end

    ShowFzfBuffers()
end

-- Switch buffers (should be in sync with fzf parts in tui/terminal)
vim.keymap.set({'i', 'n', 's', 't'}, '<C-Up>', NvimIdeBuffers, silent_opts)
vim.keymap.set({'i', 'n', 's', 't'}, '<C-Down>', NvimIdeBuffers, silent_opts)

-- Win/Buf navigation using 'jumps'
-- TODO: test 'set jumpoptions+=stack' behaviour

local nvim_ide_windows_group = vim.api.nvim_create_augroup("NvimIdeWindows", {clear = true})
vim.api.nvim_create_autocmd("VimEnter", {
    group = nvim_ide_windows_group,
    pattern = "*",
    callback = function()
        vim.cmd("clearjumps")
    end,
})

function NvimIdeJumpPrev()
    if GotoCodeWindow() then
          vim.cmd([[execute "normal! \<C-o>zz"]])
    end
end

function _G.NvimIdeJumpNext()
    if GotoCodeWindow() then
        vim.cmd([[execute "normal! 1\<C-i>zz"]])
    end
end

vim.keymap.set('', '<M-left>', ':lua NvimIdeJumpPrev()<CR>', silent_opts)
vim.keymap.set('i', '<M-left>', '<C-o>:lua NvimIdeJumpPrev()<CR>', silent_opts)
vim.keymap.set('s', '<M-left>', '<Esc><M-left>', opts)

vim.keymap.set('', '<M-right>', ':lua NvimIdeJumpNext()<CR>', silent_opts)
vim.keymap.set('i', '<M-right>', '<C-o>:lua NvimIdeJumpNext()<CR>', silent_opts)
vim.keymap.set('s', '<M-right>', '<Esc><M-right>', opts)

-- Quickfix window

-- TODO: 'has_quickfix_movements' detection should be rewritten: set var local for quickfix buffer which indicates should we move farward or not

local has_quickfix_movements = 0
local nvim_ide_quickfix_group = vim.api.nvim_create_augroup("NvimIdeQuickfix", {clear = true})
vim.api.nvim_create_autocmd("BufReadPost", {
    group = nvim_ide_quickfix_group,
    pattern = "quickfix",
    callback = function()
        has_quickfix_movements = 0
    end,
})

function NvimIdeCenterText()
    vim.cmd("normal! zz")
end

-- Next/prev in quickfix window. Quickfix is used for search results, 'LSP usage' results, etc.
function NvimIdeJumpQFItem(f)
    vim.cmd('exe "' .. f .. '"')
    NvimIdeCenterText()
end

function NvimIdeNextQFItem()
    local f = has_quickfix_movements and "cn" or "cc"
    NvimIdeJumpQFItem(f)
    has_quickfix_movements = true
end

-- item
-- nnoremap <M-down> :call NvimIdeNextQFItem()<CR>
vim.keymap.set('i', '<M-down>', '<C-o>:lua NvimIdeNextQFItem()<CR>', silent_opts)
vim.keymap.set('s', '<M-down>', '<Esc><M-down>', {remap = true})
--  nnoremap <M-up> :call NvimIdeJumpQFItem("cp")<CR>
vim.keymap.set('i', '<M-up>', '<C-o>:lua NvimIdeJumpQFItem("cp")<CR>', silent_opts)
vim.keymap.set('s', '<M-up>', '<Esc><M-up>', {remap = true})

-- file
-- nnoremap <M-PageDown> :call NvimIdeJumpQFItem("cnf")<CR>
vim.keymap.set('i', '<M-PageDown>', '<C-o>:lua NvimIdeJumpQFItem("cnf")<CR>', silent_opts)
vim.keymap.set('s', '<M-PageDown>', '<Esc><C-M-down>', {remap = true})
-- nnoremap <M-PageUp> :call NvimIdeJumpQFItem("cpf")<CR>
vim.keymap.set('i', '<M-PageUp>', '<C-o>:lua NvimIdeJumpQFItem("cpf")<CR>', silent_opts)
vim.keymap.set('s', '<M-PageUp>', '<Esc><C-M-up>', {remap = true})

-- Close quickfix window.
function NvimIdeClearAndCloseQuickfix()
    local is_qf = IsCurrBufQuickFix()
    vim.cmd('cclose')
    vim.fn.setqflist({}, 'r')
    
    if is_qf then
        vim.cmd('wincmd p')
    end
end

-- TODO: possibly detection quickfix existence should be checked to close it under condition and move to insert mode
vim.keymap.set('n', '<Esc>', ':lua NvimIdeClearAndCloseQuickfix()<CR>i', silent_opts)

function NvimIdeQuickfixPostprocess(ptrn)
    NvimIdeHighlightQuickfix(ptrn)
    -- Goto previous windows (probably with code)
    vim.cmd('wincmd p')
end

-- Tabline settings
function NvimIdeTabLine()
    local s = ''
    for i = 1, vim.fn.tabpagenr('$') do
        -- select the highlighting
        if i == vim.fn.tabpagenr() then
            s = s .. '%#TabLineSel#'
        else
            s = s .. '%#TabLine#'
        end

        -- set the tab page number (for mouse clicks)
        s = s .. '%' .. i .. 'T'

        -- the label is made by NvimIdeTabLabel()
        s = s .. '\u{258f}' .. '%{v:lua.NvimIdeTabLabel(' .. i .. ')} '
    end

    -- after the last tab fill with TabLineFill and reset tab page nr
    s = s .. '%#TabLineFill#%T'

    -- right-align the label to close the current tab page
    if vim.fn.tabpagenr('$') > 1 then
        s = s .. '%=%#TabLine#%999XX'
    end

    return s
end

function NvimIdeTabLabel(n)
    local label = ''
    local bufnrlist = vim.fn.tabpagebuflist(n)

    -- Add '+' if one of the buffers in the tab page is modified
    for _, bufnr in ipairs(bufnrlist) do
        if vim.fn.getbufvar(bufnr, "&modified") == 1 then
            label = '+'
            break
        end
    end

    -- Append the number of windows in the tab page if more than one
    local wincount = vim.fn.tabpagewinnr(n, '$')
    if wincount > 1 then
        label = label .. wincount
    end
    if label ~= '' then
        label = label .. ' '
    end

    -- Append the buffer name
    local active_win_in_tab = vim.fn.tabpagewinnr(n)
    local active_bufnr = bufnrlist[active_win_in_tab]
    return label .. vim.fn.fnamemodify(vim.fn.bufname(active_bufnr), ':t')
end

vim.opt.tabline = '%!v:lua.NvimIdeTabLine()'

