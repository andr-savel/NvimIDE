local prefix = "source " .. os.getenv("HOME") .. "/.config/nvim/tui/"

vim.cmd(prefix .. "project.lua")
vim.cmd(prefix .. "plugins.lua")
vim.cmd(prefix .. "editor.lua")
vim.cmd(prefix .. "file.lua")
if vim.g.nvim_ide_project_root ~= nil then
    vim.cmd(prefix .. "search_in_content.lua")
end
vim.cmd(prefix .. "search_map.lua")
vim.cmd(prefix .. "terminal.lua")
vim.cmd(prefix .. "win_buf.lua")

