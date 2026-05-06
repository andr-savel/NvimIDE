-- obligatory variables
vim.g.nvim_ide_project_root = vim.fn.getenv('PWD')

-- optional variables
--     fzf source
--         with additional files exclusion (some systems support -g option value only with double quotes: 'rg --files -g "\!*.o"')
vim.g.nvim_ide_fzf_source = 'rg --files -L -g \\!build -g \\!*.o -g \\!*pb.h -g \\!*pb.cc -g \\!*_pb2.py'
--         or from git files (auto-select example: nnoremap <expr> <C-p> (len(system('git rev-parse')) ? ':Files' : ':GFiles')."\<cr>")
-- vim.g.nvim_ide_fzf_source = 'git ls-files'

--     basic command for search in project files content (some systems support -g option value only with double quotes: 'rg --vimgrep --smart-case -g "\!build_*"')
vim.g.nvim_ide_content_search_rg_basic_cmd = 'rg --vimgrep --smart-case -g \\!build*'

--     commang for compilation database generation for C/C++
vim.g.nvim_ide_cpp_compilation_database_command = vim.g.nvim_ide_project_root .. '/generate_compile_database.sh'
--     num threads for C/C++ language server
vim.g.nvim_ide_cpp_language_server_threads = 8

--     build root (for cmake project, for exmaple, build root can differ from project root)
vim.g.nvim_ide_build_root = vim.g.nvim_ide_project_root .. '/build/Debug'
--     build command for project (C/C++, go)
vim.g.nvim_ide_build_command = 'cmake --build ' .. vim.g.nvim_ide_build_root .. ' --target all -- -j8'

--     Debugger settings
--         path to binary (or package dir for golang) which should be debugged
vim.g.nvim_ide_debuggee_binary_path = vim.g.nvim_ide_project_root .. '/build/Debug/demo'
--         arguments for debuggee binary
vim.g.nvim_ide_debuggee_binary_args = {}

--     switch-on icons (needs patched font, see README.md for details)
vim.g.nvim_ide_allow_icons = true

