vim.keymap.set({'n', 'i'}, '<C-h>', function()
    if vim.bo.filetype == "neo-tree" then
        vim.cmd('NeoTreeClose')
    else
        if vim.g.nvim_ide_project_root then
            vim.cmd('Neotree toggle dir=' .. vim.g.nvim_ide_project_root)
        else
            vim.cmd('Neotree toggle')
        end
    end
end)

local function startInsertMode(arg)
    vim.cmd('startinsert')
end

local function stopInsertMode(arg)
    vim.cmd('stopinsert')
end

require("neo-tree").setup({
    enable_diagnostics = false,
    enable_git_status = true,
    filesystem = {
        filtered_items = {
--            visible = false, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = true,
            hide_gitignored = false,
        },
--        follow_current_file = true, -- This will find and focus the file in the active buffer every
                                    -- time the current file is changed while the tree is open.
        use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
                                       -- instead of relying on nvim autocmd events.
        bind_to_cwd = false, -- true creates a 2-way binding between vim's cwd and neo-tree's root
    },
    window = {
        mappings = {
            ["<M-c>"] = "close_window"
        }
    },
    event_handlers = {
        {
            event = "neo_tree_buffer_enter",
            handler = stopInsertMode
        },
        {   
            event = "neo_tree_buffer_leave",
            handler = startInsertMode
        },
        {
            event = "neo_tree_window_after_open",
            handler = stopInsertMode
        },
        {
            event = "neo_tree_window_after_close",
            handler = startInsertMode
        }
    }
})

