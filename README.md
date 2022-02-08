# NvimIDE
nvim/nvim-qt configuration for C++/Python/Go

## Installation
The following steps should be done to install NvimIde:
1) pip install neovim
   pip3 install neovim
2) Install nvim or nvim-qt
3) start nvim
4) Execute the following command:
    PlugInstall
5) Make sure that all plugins has been installed
6) Close nvim
7) Start nvim again

## Usage
To use NvimIde project config file should be created. See 'doc/project.conf' example for details.

Then nvim should be started with mentioned config file (this file will be sourced first, before other NvimIde files):

    nvim --cmd "source /path/to/project/config/file"
    
or

    nvim-qt -- --cmd "source /path/to/project/config/file"

