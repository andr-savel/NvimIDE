require('fzf-lua').setup({
    winopts = {
        preview = {hidden = 'hidden'},
        row    = 0.5,
        col    = 0.5,
        width  = 0.9,
        height = 0.7,

        backdrop = 90 -- color outside the fzf window is different a little bit from fzf window
    },
    fzf_opts = {
        ['--info']   = 'hidden',
        ['--layout'] = 'reverse',
        ['--cycle']  = '',
        ['--exact']  = '',
        ['--expect'] = 'esc'
    },
    keymap = {
        fzf = {
            ["alt-up"]     = "prev-history",
            ["alt-down"]   = "next-history",
            ["shift-down"] = "toggle+down",
            ["shift-up"]   = "toggle+up",
            ["ctrl-a"]     = "select-all"
        },
    }
})

