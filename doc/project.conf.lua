-- This file contains example of all possible variables which can be specified for particular project

-- obligatory variables
vim.g.nvim_ide_project_root = "/root/directory/of/the/project"


-- optional variables
--     fzf source
--         with additional files exclusion (some systems support -g option value only with double quotes: 'rg --files -g "\!*.o"')
vim.g.nvim_ide_fzf_source = 'rg --files -L -g \!*.o -g \!*pb.h -g \!*pb.cc -g \!*_pb2.py'
--         or from git files (auto-select example: nnoremap <expr> <C-p> (len(system('git rev-parse')) ? ':Files' : ':GFiles')."\<cr>")
vim.g.nvim_ide_fzf_source = 'git ls-files'

--     basic command for search in project files content (some systems support -g option value only with double quotes: 'rg --vimgrep --smart-case -g "\!build_*"')
vim.g.nvim_ide_content_search_rg_basic_cmd = 'rg --vimgrep --smart-case -g \!build_* -g \!user_data'

--     commang for compilation database generation for C/C++
vim.g.nvim_ide_cpp_compilation_database_command = vim.g.nvim_ide_project_root .. '/generate_compile_database.sh'
--     num threads for C/C++ language server
vim.g.nvim_ide_cpp_language_server_threads = 8

--     build root (for cmake project, for exmaple, build root can differ from project root)
vim.g.nvim_ide_build_root = vim.g.nvim_ide_project_root .. "/build"
--     build command for project (C/C++, go)
vim.g.nvim_ide_build_command = "mkdep"

--     Debugger settings
--         path to binary (or package dir for golang) which should be debugged
vim.g.nvim_ide_debuggee_binary_path = '/path/to/debuggee'
--         arguments for debuggee binary
vim.g.nvim_ide_debuggee_binary_args = {'arg1', 'arg2', 'arg3'}

--     switch-on icons (needs patched font, see README.md for details)
vim.g.nvim_ide_allow_icons = true

