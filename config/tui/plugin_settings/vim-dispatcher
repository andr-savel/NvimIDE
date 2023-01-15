vim.keymap.set({'n', 'i'}, '<f8>', function()
    cwd_au = vim.fn.getcwd()

    if vim.g.nvim_ide_build_root then
        vim.cmd('lcd ' .. vim.g.nvim_ide_build_root)
    end

    vim.cmd('wa')
    vim.cmd('Make')

    if vim.g.nvim_ide_build_root then 
        vim.cmd('lcd ' .. cwd_au)
    end
end)

vim.keymap.set({'n', 'i'}, '<f7>', function()
    vim.cmd('AbortDispatch')
end)

