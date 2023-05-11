local cb = require'diffview.config'.diffview_callback
local opt = {noremap = true, silent = true, nowait = true}

local function LineGE(newLine, line)
    return newLine >= line
end

local function LineLE(newLine, line)
    return newLine <= line
end

local function SelectFileEntry(arg, direction, lineCmp, wrnMessage)
    line = vim.api.nvim_win_get_cursor(vim.t.nvim_ide_diffview_files_win_id)[1]
    cb(direction)(arg)
    newLine = vim.api.nvim_win_get_cursor(vim.t.nvim_ide_diffview_files_win_id)[1]
    print(newLine, line)
    if lineCmp(newLine, line) then
        vim.cmd("normal! /")
    else
        vim.fn.NvimIdeEchoWarning(wrnMessage)
    end
end

require'diffview'.setup {
    diff_binaries = false,                    -- Show diffs for binaries
    enhanced_diff_hl = false,                 -- See ':h diffview-config-enhanced_diff_hl'
    use_icons = vim.g.nvim_ide_allow_icons,   -- Requires nvim-web-devicons
    icons = {                                 -- Only applies when use_icons is true.
        folder_closed = "",
        folder_open = "",
    },
    signs = {
        fold_closed = "",
        fold_open = "",
    },
    file_panel = {
        win_config = {
            position = "left",              -- One of 'left', 'right', 'top', 'bottom'
            width = 35,                     -- Only applies when position is 'left' or 'right'
            height = 10                     -- Only applies when position is 'top' or 'bottom'
        },
        listing_style = "tree",             -- One of 'list' or 'tree'
        tree_options = {                    -- Only applies when listing_style is 'tree'
            flatten_dirs = true,              -- Flatten dirs that only contain one single dir
            folder_statuses = "only_folded",  -- One of 'never', 'only_folded' or 'always'.
        },
    },
    file_history_panel = {
        win_config = {
            position = "bottom",
            width = 35,
            height = 16
        },
        log_options = {
            git = {
                single_file = {
                    max_count = 256,      -- Limit the number of commits
                    follow = false,       -- Follow renames (only for single file)
                    all = false,          -- Include all refs under 'refs/' including HEAD
                    merges = false,       -- List only merge commits
                    no_merges = false,    -- List no merge commits
                    reverse = false       -- List commits in reverse order
                },
                multi_file = {
                    max_count = 256,      -- Limit the number of commits
                    follow = false,       -- Follow renames (only for single file)
                    all = false,          -- Include all refs under 'refs/' including HEAD
                    merges = false,       -- List only merge commits
                    no_merges = false,    -- List no merge commits
                    reverse = false       -- List commits in reverse order
                }
            }
        },
    },
    default_args = {    -- Default args prepended to the arg-list for the listed commands
        DiffviewOpen = {},
        DiffviewFileHistory = {},
    },
    hooks = {
        view_opened = function(view)
            vim.t.nvim_ide_diffview_files_win_id = vim.api.nvim_get_current_win()
            -- goto left diff window
            vim.cmd('wincmd w')
            vim.cmd('wincmd w')
        end,
        diff_buf_read = function(bufnr)
            vim.opt_local.scrolloff=999

            vim.api.nvim_buf_set_keymap(bufnr, "n", "<M-down>", "]c", opt)
            vim.api.nvim_buf_set_keymap(bufnr, "n", "<M-up>", "[c", opt)
            vim.api.nvim_buf_set_keymap(bufnr, "i", "<M-down>", "<C-o>]c", opt)
            vim.api.nvim_buf_set_keymap(bufnr, "i", "<M-up>", "<C-o>[c", opt)
        end,
        view_closed = function(view)
            vim.cmd('startinsert')
        end
    },
    key_bindings = {
        disable_defaults = true,                   -- Disable the default key bindings
        -- The `view` bindings are active in the diff buffers, only when the current
        -- tabpage is a Diffview.
        view = {
            {{"n", "i"}, "<M-PageDown>", function(arg)
                SelectFileEntry(arg, "select_next_entry", LineGE, "files hit BOTTOM, continuing at TOP")
            end, opt},
            {{"n", "i"}, "<M-PageUp>", function(arg)
                SelectFileEntry(arg, "select_prev_entry", LineLE, "files hit TOP, continuing at BOTTOM")
            end, opt},
            {{"n", "i"}, "<M-s>", cb("toggle_stage_entry"), opt},
            ["<leader>e"]  = cb("focus_files"),        -- Bring focus to the files panel
            ["<leader>b"]  = cb("toggle_files"),       -- Toggle the files panel.
        },
        file_panel = {
            {{"n", "i"}, "<down>", cb("next_entry"), opt},
            {{"n", "i"}, "<up>", cb("prev_entry"), opt},
            {{"n", "i"}, "<cr>", cb("select_entry"), opt},    -- Open the diff for the selected entry.
            {{"n", "i"}, "<M-s>", cb("toggle_stage_entry"), opt},
            {{"n", "i"}, "<2-LeftMouse>", cb("select_entry"), opt},
            {{"n", "i"}, "<M-PageDown>", cb("select_next_entry"), opt},
            {{"n", "i"}, "<M-PageUp>", cb("select_prev_entry"), opt},
            ["<leader>e"]     = cb("focus_files"),
            ["<leader>b"]     = cb("toggle_files"),
        },
        file_history_panel = {
            {{"n", "i"}, "<down>", cb("next_entry"), opt},
            {{"n", "i"}, "<up>", cb("prev_entry"), opt},
            {{"n", "i"}, "<cr>", cb("select_entry"), opt},
            {{"n", "i"}, "<2-LeftMouse>", cb("select_entry"), opt},
            {{"n", "i"}, "<M-PageDown>", cb("select_next_entry"), opt},
            {{"n", "i"}, "<M-PageUp>", cb("select_prev_entry"), opt},
            ["<leader>e"]     = cb("focus_files"),
            ["<leader>b"]     = cb("toggle_files"),
        },
    },
}

local function OpenDiff()
    untrackedFiles = "--untracked-files=no"

    fileToSelect = ""
    firstFileStatus = vim.fn.split(vim.fn.system('git status --short ' .. untrackedFiles .. ' | head -n 1'))
    if #firstFileStatus >=2 then
        fileToSelect = " --selected-file=" .. firstFileStatus[2]
    end

    vim.cmd('DiffviewOpen ' .. untrackedFiles .. ' -C' .. vim.g.nvim_ide_project_root .. fileToSelect)
    vim.cmd("stopinsert")
    vim.cmd("DiffviewRefresh")
end

vim.keymap.set({'n', 'i'}, '<M-d>', OpenDiff)

local function OpenFileHistory()
    vim.cmd('DiffviewFileHistory' .. vim.g.nvim_ide_project_root)
    vim.cmd("stopinsert")
end

vim.keymap.set({'n', 'i'}, '<M-h>', OpenFileHistory)

-- To close diffview tab type <C-d>

