-- Enter to 'terminal mode'
-- i

-- Open new terminal
--vim.keymap.set('n', '<M-t>', '<C-g>term<CR>', {silent = true})
vim.keymap.set('n', '<M-t>', ':term<CR>', {silent = true})
vim.keymap.set('i', '<M-t>', '<Esc>:term<CR>', {silent = true})
--vim.keymap.set('t', '<M-t>', [[<C-\><C-N><C-g>term<CR>]], {silent = true})
vim.keymap.set('t', '<M-t>', [[<C-\><C-N><C-g>term<CR>]], {silent = true, remap = true})

local group = vim.api.nvim_create_augroup("NvimIdeTerminalAutocmds", {clear = true})

-- Open terminal in 'terminal' mode (can execute shell commands immediately)
vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    pattern = "*",
    command = "startinsert"
})

-- Leave terminal mode
vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    pattern = "*",
    callback = function()
        if vim.bo.filetype == 'fzf' or vim.api.nvim_buf_get_name(0):match("fzf") then
            return
        end

        vim.keymap.set('t', '<ESC><ESC>', [[<C-\><C-N>]], {buffer = true})
    end
})

-- Postprocess and maps restore
vim.api.nvim_create_autocmd("TermClose", {
    group = group,
    pattern = "*",
    callback = function()
        -- Change buffer mode to 'insert' when close terminal. It helps to open files selected with fzf in 'insert' mode
        if not vim.g.nvim_ide_starting_debug_attach then
            vim.api.nvim_feedkeys("i", "n", false)
        end
        vim.g.nvim_ide_starting_debug_attach = false
    end
})

-- TODO: enter to 'terminal' mode on 'switch buffer'

