require("claudecode").setup({
    terminal_cmd = "deepclaude",
    terminal = {
        provider = "native",
        split_side = "right",
        split_width_percentage = 0.35,
        cwd = vim.g.nvim_ide_real_project_root or vim.fn.getcwd(),
    },
    diff_opts = {
        layout = "vertical",
        open_in_new_tab = true,
        keep_terminal_focus = true,
    },
    focus_after_send = true,
})

vim.keymap.set({ 'n', 'i' }, '<C-.>', '<cmd>ClaudeCode<CR>')
vim.keymap.set('t', '<C-.>', [[<C-\><C-N><cmd>ClaudeCode<CR><cmd>startinsert<CR>]])

vim.opt.autoread = true
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local watcher = vim.uv.new_fs_event()
        if not watcher then return end
        watcher:start(vim.g.nvim_ide_real_project_root or vim.fn.getcwd(), {},
            vim.schedule_wrap(function(err)
                if not err then vim.cmd("checktime") end
            end))
    end,
})
