-- Default values for optional project settings

vim.g.nvim_ide_start_dir = vim.fn.getcwd()

if vim.g.nvim_ide_project_root then
    vim.g.nvim_ide_real_project_root = vim.fn.resolve(vim.g.nvim_ide_project_root)
end

--     Source for fzf
vim.g.nvim_ide_fzf_source = vim.g.nvim_ide_fzf_source or 'rg --files -L'

--     Basic line for search in project files content using ripgrep
vim.g.nvim_ide_content_search_rg_basic_cmd = vim.g.nvim_ide_content_search_rg_basic_cmd or 'rg --vimgrep --smart-case'


-- Project configuration
--     Directory for extra files
local project_extra_files_dir = ''
function NvimIdeGetProjectExtraFilesDir()
    if not vim.g.nvim_ide_project_root then
        return "/tmp"
    end

    if project_extra_files_dir == '' then
        project_extra_files_dir = vim.g.nvim_ide_project_root .. '/.nvim_ide_project_extra'
        if vim.fn.isdirectory(project_extra_files_dir) == 0 then
            vim.fn.mkdir(project_extra_files_dir)
        end
    end

    return project_extra_files_dir
end

if vim.g.nvim_ide_cpp_compilation_database_command then
    --     Num threads for C/C++ language server
    vim.g.nvim_ide_cpp_language_server_threads = vim.g.nvim_ide_cpp_language_server_threads or 4
end

local function regen_compdb()
    if vim.g.nvim_ide_cpp_compilation_database_command then
        vim.cmd('Dispatch ' .. vim.g.nvim_ide_cpp_compilation_database_command)
    end
end
vim.api.nvim_create_user_command('NvimIdeRegenCompdb', regen_compdb, {})

local function initial_comp_db_creation()
    if not vim.g.nvim_ide_cpp_compilation_database_command or not vim.g.nvim_ide_project_root then
        return
    end

    --      Gen compilation database
    local compile_commands_path = vim.g.nvim_ide_project_root .. "/compile_commands.json"
    if vim.fn.empty(vim.fn.glob(compile_commands_path)) == 1 then
        regen_compdb()
    end
end

local group = vim.api.nvim_create_augroup("NvimIdeGetCppCompDb", {clear = true})
vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = initial_comp_db_creation,
})

--     Build command for project (C/C++, go)
if vim.g.nvim_ide_build_command then
    vim.opt.makeprg = vim.g.nvim_ide_build_command
end

--     Settings for debugger
vim.g.nvim_ide_debuggee_binary_path = vim.g.nvim_ide_debuggee_binary_path or ''
vim.g.nvim_ide_debuggee_binary_args = vim.g.nvim_ide_debuggee_binary_args or {}

--     Icons
if vim.g.nvim_ide_allow_icons == nil then
    vim.g.nvim_ide_allow_icons = false
end

