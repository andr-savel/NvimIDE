local prefix = "source " .. os.getenv("HOME") .. "/.config/nvim/tui/"

vim.cmd(prefix .. "project.lua")
vim.cmd(prefix .. "plugins")
vim.cmd(prefix .. "editor")
vim.cmd(prefix .. "file")
if vim.g.nvim_ide_project_root ~= nil then
    vim.cmd(prefix .. "search_in_content")
end
vim.cmd(prefix .. "search_map")
vim.cmd(prefix .. "terminal")
vim.cmd(prefix .. "win_buf")

