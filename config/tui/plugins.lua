-- Get lazy.nvim plugin manager and inistall plugins

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        'sainnhe/gruvbox-material',
        lazy = false,
        priority = 1    -- before lualine.nvim
    },

    {
        "ibhagwan/fzf-lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        }
    },

    {'linrongbin16/lsp-progress.nvim'},

    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-vsnip',
            'hrsh7th/vim-vsnip',
        },
    },

    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'nvim-neotest/nvim-nio'
        },
    },

    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate'
    },

    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons'
        },
        priority = 2    -- after gruvbox-material
    },
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v3.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons',
            'MunifTanjim/nui.nvim'
        },
    },

    {'sindrets/diffview.nvim'},
    {'APZelos/blamer.nvim'},

    {'tpope/vim-dispatch'},
    {'windwp/nvim-autopairs'},

    {"coder/claudecode.nvim"}
})

-- Plugin settings

local prefix_part = vim.fn.stdpath("config") .. "/tui/plugin_settings/"
local prefix = "source " .. prefix_part

vim.cmd(prefix .. "colortheme.lua")
vim.cmd(prefix .. "nvim-web-devicons.lua")
vim.cmd(prefix .. "fzf-lua.lua")
vim.cmd(prefix .. "nvim-cmp.lua")
vim.cmd(prefix .. "treesitter.lua")
if vim.g.nvim_ide_project_root ~= nil then
    vim.cmd(prefix .. "fzf_lsp.lua")
    vim.cmd(prefix .. "lsp.lua")
    vim.cmd(prefix .. "dap.lua")
    vim.cmd(prefix .. "diffview.lua")
end
vim.cmd(prefix .. "claudecode.lua")
vim.cmd(prefix .. "neo-tree.nvim.lua")
vim.cmd(prefix .. "lualine.lua")
vim.cmd(prefix .. "blamer.lua")
vim.cmd(prefix .. "vim-dispatcher.lua")
vim.cmd(prefix .. "nvim-autopairs.lua")

