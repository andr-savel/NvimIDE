# NvimIDE
nvim/nvim-qt configuration for C++/Python/Go

## Installation
The following steps should be done to install NvimIde:
1) Install nvim or nvim-qt
2) start nvim
3) Execute the following command:
    PlugInstall
4) Make sure that all plugins has been installed

## Usage
To use NvimIde project config file should be created. See 'doc/project.conf' example for details.

Then nvim should be started with mentioned config file:

    nvim -S /path/to/project/config/file
    
or

    nvim-qt -- -S /path/to/project/config/file

