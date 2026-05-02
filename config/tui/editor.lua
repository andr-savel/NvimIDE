-- Set 'insert' mode as default
vim.cmd('startinsert')

-- zero delay for <Esc>
vim.env.ESCDELAY = "0"

-- Enable mouse for all modes
vim.opt.mouse = 'a'

-- Copy selected or yanked text by <MiddleMouse> button
local opts = { noremap = true }
vim.keymap.set('s', '<MiddleMouse>', '<C-g>y<LeftMouse><C-g>gP', opts)
vim.keymap.set('i', '<MiddleMouse>', '<LeftMouse><C-o>gP', opts)
vim.keymap.set('n', '<MiddleMouse>', '<LeftMouse>gP', opts)

-- Do not show mode in cmd line
vim.opt.showmode = false

-- Remove '~' char for empty lines
vim.opt.fillchars = { eob = ' ' }

-- set blinking cursor
vim.opt.guicursor = "i-ci-ve:ver25-Cursor/lCursor-blinkwait175-blinkoff150-blinkon175"

-- display line numbers
vim.opt.number = true

-- always display sign column (for example, lsp diagnostic erros set appropriate character here)
vim.opt.signcolumn = 'yes'

-- tab settings
vim.opt.tabstop = 8
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.smarttab = true

-- Show warning message on search after last match (and do not show search progress 'x/y')
vim.opt.shortmess:append('S')

local group = vim.api.nvim_create_augroup('NvimIdePerLangAutoCmds', {clear = true})
vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'go',
    callback = function()
        -- tabs but not spaces for golang
        vim.opt_local.expandtab = false
    end,
})

-- indents
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true

-- prevent escape from moving the cursor one character to the left
local CursorColumnI = 0 -- the cursor column position in INSERT
vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    callback = function()
        CursorColumnI = vim.fn.col('.')
    end,
})
vim.api.nvim_create_autocmd("CursorMovedI", {
    pattern = "*",
    callback = function()
        CursorColumnI = vim.fn.col('.')
    end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = "*",
    callback = function()
        if vim.fn.col('.') ~= CursorColumnI then
            vim.fn.cursor(0, vim.fn.col('.') + 1)
        end
    end,
})

-- set 'selection', 'selectmode', 'mousemodel' and 'keymodel' for MS-Windows
-- behave mswin
-- runtime mswin.vim
vim.cmd([[source $VIMRUNTIME/scripts/mswin.vim]])

-- backspace and cursor keys wrap to previous/next line
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.whichwrap:append("<,>,[,]")

-- copy/paste to/from system clipboard
vim.opt.clipboard:append("unnamedplus")

-- CTRL-X is Cut
vim.keymap.set("v", "<C-x>", "d<Esc>i")

-- CTRL-C is Copy
vim.keymap.set("v", "<C-c>", "y")

-- CTRL-V is Paste
vim.keymap.set("", "<C-v>", "gPi")
vim.keymap.set("i", "<C-v>", "<Left><Right><C-O>gP")
vim.keymap.set("v", "<C-v>", "<C-O>gP")
vim.keymap.set("s", "<C-v>", '<C-g>"_dgP')
vim.keymap.set("c", "<C-v>", "<C-r>=getreg()<CR>")
--     in 'terminal' mode
vim.keymap.set('t', '<C-v>', [[<C-\><C-N>"+pi]], {noremap = true})

-- Do not copy deleted text into 'default', but into 'blackhole' register
local nvim_ide_map = vim.api.nvim_create_augroup("NvimIdeMap", {clear = true})
vim.api.nvim_create_autocmd("VimEnter", {
    group = nvim_ide_map,
    pattern = "*",
    callback = function()
        vim.keymap.set("s", "<BS>", '<C-g>"_d', {buffer = true})
    end,
})
vim.keymap.set("s", "<Del>", '<C-g>"_d')

-- CTRL-Z is Undo
vim.keymap.set("", "<C-z>", "u")
vim.keymap.set("i", "<C-z>", "<C-O>u")
vim.keymap.set("s", "<C-z>", "<Esc><C-z>")

-- ALT-z is Redo
vim.keymap.set('n', '<M-z>', '<C-r>')
vim.keymap.set('i', '<M-z>', '<C-O><C-r>')
vim.keymap.set('s', '<M-z>', '<Esc><C-r>')

--    it is the same 'Redo' action but with <C-S-z> map which works correctly with alacritty special setting for 'Z' key (see utils/alacritty.yml for details)
vim.keymap.set('n', '<C-S-z>', '<C-r>')
vim.keymap.set('i', '<C-S-z>', '<C-O><C-r>')
vim.keymap.set('s', '<C-S-z>', '<Esc><C-r>')

-- CTRL-A is Select all
vim.keymap.set('', '<C-A>', 'gggH<C-O>G')
vim.keymap.set('i', '<C-A>', '<C-O>gg<C-O>gH<C-O>G')
vim.keymap.set('c', '<C-A>', '<C-C>gggH<C-O>G')
vim.keymap.set('o', '<C-A>', '<C-C>gggH<C-O>G')
vim.keymap.set('s', '<C-A>', '<C-C>gggH<C-O>G')
vim.keymap.set('x', '<C-A>', '<C-C>ggVG')

-- Tab selected text
-- snoremap <Tab> <C-g>>
vim.keymap.set('s', '<Tab>', '<C-o>=')

-- Goto begin/end of file
-- <C-home>
-- <C-end>

-- <Home> or move to first non 'space' symbol
vim.keymap.set('i', '<Home>', function()
    return vim.fn.getcurpos()[3] == 1 and '<C-right>' or '<Home>'
end, {expr = true})
vim.keymap.set('n', '<Home>', function()
    return vim.fn.getcurpos()[3] == 1 and '<C-right>' or '<Home>'
end, {expr = true})
vim.keymap.set('i', '<S-Home>', function()
    return vim.fn.getcurpos()[3] == 1 and '<C-o><C-S-right>' or '<S-Home>'
end, {expr = true})
vim.keymap.set('s', '<S-Home>', function()
    return vim.fn.getcurpos()[3] == 1 and '<C-o><C-S-right>' or '<S-Home>'
end, {expr = true})

-- Goto open/close bracket
vim.keymap.set('i', '<C-p>', '<C-o>%')
vim.keymap.set('', '<C-p>', '%')

-- Goto line
vim.keymap.set('', '<C-g>', ':')
vim.keymap.set('i', '<C-g>', '<C-O>:')
vim.keymap.set('s', '<C-g>', '<Esc>:')

-- Proper scroll
vim.keymap.set('', '<PageUp>', '1000<C-u>', {silent = true})
vim.keymap.set('', '<PageDown>', '1000<C-d>', {silent = true})
vim.keymap.set('i', '<PageUp>', '<C-o>1000<C-u>', {silent = true})
vim.keymap.set('i', '<PageDown>', '<C-o>1000<C-d>', {silent = true})
vim.keymap.set('s', '<PageUp>', '<Esc>1000<C-u>', {silent = true})
vim.keymap.set('s', '<PageDown>', '<Esc>1000<C-d>', {silent = true})

-- Deselect current selection to prevent extend selection on scroll
vim.keymap.set('s', '<ScrollWheelUp>', '<Esc><ScrollWheelUp>')
vim.keymap.set('s', '<ScrollWheelDown>', '<Esc><ScrollWheelDown>')


vim.api.nvim_create_user_command('NvimIdeFullFilePath', function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg('+', path)
    print(path)
end, {})

-- <Esc> complex behaviour
vim.keymap.set('i', '<Esc>', function()
    return vim.v.hlsearch == 1 and '<C-O>:noh<CR>' or '<Esc>'
end, { expr = true, silent = true })

-- function! NvimIdeHasSignatureFloatingWindow()
--     return len(filter(nvim_list_wins(), {k,v->nvim_win_get_config(v).relative == "win"})) == 1
-- endfunction
--
-- --     Map <Esc> to close 'signature' floating window if it exests. Note that '<M-/>' map should be in sync with 'lsp_signature.toggle_key' value from 'plugin_settings/lsp' file
-- inoremap <silent> <expr> <Esc> (NvimIdeHasSignatureFloatingWindow() ? '<C-o>:call feedkeys("\<M-/>")<CR>' : (v:hlsearch == 1 ? '<C-O>:noh<CR>' : '<Esc>'))

