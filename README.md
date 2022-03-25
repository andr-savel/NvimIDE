# NvimIDE
nvim/nvim-qt configuration for C++/Python/Go

## Installation
The following steps should be done to install NvimIde:
1) Install 'nvim' (or 'nvim-qt'), 'curl'
2) Install python support for nvim
```
    pip install neovim
    pip3 install neovim
```
3) Install C/C++ language server 'ccls' (it is better to clone git repo and compile it)
4) Install lldb (C/C++ debugger)
5) Install 'compdb' (creates compilation database for C/C++ projects)
```
    pip install compdb
```
and export path to binary into PATH env var.
Then
```
cd <project_root>
ln -s <path_to_nvim_ide>/utils/generate_compile_database.sh .
mkdir build
cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 ..
```
To build with debug info use the following command instead:
```
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_BUILD_TYPE=Debug ..
```
After this manipulations NvimIde ready to index C/C++ code using g:nvim_ide_cpp_compilation_database_command

6) Install go language server

For new go versions
```
    go install golang.org/x/tools/gopls@latest
```
For old go versions:
```
    export GO111MODULE=on
    go get golang.org/x/tools/gopls@latest
    export PATH=$HOME/go/bin:$PATH
```
7) To use fast search in whole project install 'ripgrep'
8) To use system clipboard please install 'xclip'.

9) Link files from this repo to nvim dir
```
    ln -s <cloned_repo_path>/config/* ~/.config/nvim
```
10) Start nvim
First run leads to many errors because no plugins have been installed.
Please install it manually via
```
:PlugInstall
```
11) Close nvim
12) Start nvim again with --cmd option (see below) to install part of DAP adapters for 'vimpector' plugin

## Usage
To use NvimIde project config file should be created. See 'doc/project.conf' example for details.

Then nvim should be started with mentioned config file (this file will be sourced first, before other NvimIde files):
```
    nvim --cmd "source /path/to/project/config/file"
```
or
```
    nvim-qt -- --cmd "source /path/to/project/config/file"
```
