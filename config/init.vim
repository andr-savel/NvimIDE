function! NvimIdeInit()
    source $HOME/.config/nvim/tui/project

    source $HOME/.config/nvim/tui/plugins

    source $HOME/.config/nvim/tui/editor
    source $HOME/.config/nvim/tui/file
    source $HOME/.config/nvim/tui/search_in_content
    source $HOME/.config/nvim/tui/search_map
    source $HOME/.config/nvim/tui/terminal
    source $HOME/.config/nvim/tui/win_buf
    source $HOME/.config/nvim/tui/lsp
endfunction

" 'source' commands should be called from autocmd for 'VimEnter' event to provide the following config load sequence:
"     1) Project settings (file provided to neovim through the '-S' cmd-line argument)
"     2) NvimIdeInit() configs

augroup NvimIdeInitAutocmd
    autocmd!
    autocmd VimEnter * call NvimIdeInit()
augroup END

