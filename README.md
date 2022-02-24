# NvimIDE
nvim/nvim-qt configuration for C++/Python/Go

## Installation
The following steps should be done to install NvimIde:
1) Install nvim or nvim-qt
2) Install python support for nvim
    pip install neovim
    pip3 install neovim
3) Install go language server
For new go versions
    go install golang.org/x/tools/gopls@latest
For old go versions:
    export GO111MODULE=on
    go get golang.org/x/tools/gopls@latest
    export PATH=$HOME/go/bin:$PATH
4) Start nvim and install plugins
    nvim +PlugInstall
5) Make sure that all plugins has been installed
6) Close nvim
7) Start nvim again

## Usage
To use NvimIde project config file should be created. See 'doc/project.conf' example for details.

Then nvim should be started with mentioned config file (this file will be sourced first, before other NvimIde files):

    nvim --cmd "source /path/to/project/config/file"
    
or

    nvim-qt -- --cmd "source /path/to/project/config/file"

