-- Save all changed files
vim.keymap.set('n', '<C-s>', ':wa<CR>')
vim.keymap.set('i', '<C-s>', '<C-O>:wa<CR>')

-- Close all files and quit
vim.keymap.set('n', '<M-Esc>', ':qa<CR>')
vim.keymap.set('i', '<M-Esc>', '<C-O>:qa<CR>')
--     in 'terminal' mode
vim.keymap.set('t', '<M-Esc>', [[<C-\><C-N>:qa<CR>]])

