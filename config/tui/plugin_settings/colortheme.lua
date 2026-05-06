-- Colorscheme settings
vim.opt.termguicolors = true

vim.o.background = "dark"
vim.g.gruvbox_material_background = "medium"
vim.g.gruvbox_material_enable_bold = 1
vim.g.gruvbox_material_visual = "reverse"
vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
vim.g.gruvbox_material_disable_terminal_colors = 1
vim.cmd.colorscheme("gruvbox-material")

-- let g:sonokai_style = 'shusia'
-- let g:sonokai_enable_italic = 1
-- colorscheme sonokai

-- colorscheme aurora

-- Custom color settings
--     Do not use special highlight for sign column
vim.cmd("highlight clear SignColumn")

--     Line highlight
--         Enable cursor line position tracking
vim.opt.cursorline = true

--         Remove the underline from enabling cursorline
-- highlight clear CursorLine

--     Improve visibility of warning messages
vim.api.nvim_set_hl(0, "WarningMsg", {fg = "black", bg = "yellow"})

--     Set color for bracket pairs
vim.api.nvim_set_hl(0, "MatchParen", {bg = "darkcyan", fg = "NONE"})

--     Terminal colors ('DimmedMonokai_without_bright_colors' terminal emulator color theme from 'utils' repository)
vim.g.terminal_color_0  = "#3a3d43"
vim.g.terminal_color_1  = "#be3f48"
vim.g.terminal_color_2  = "#879a3b"
vim.g.terminal_color_3  = "#c5a635"
vim.g.terminal_color_4  = "#4f76a1"
vim.g.terminal_color_5  = "#855c8d"
vim.g.terminal_color_6  = "#7dd6cf"
vim.g.terminal_color_7  = "#b9bcba"
vim.g.terminal_color_8  = "#888987"
vim.g.terminal_color_9  = "#be3f48"
vim.g.terminal_color_10 = "#879a3b"
vim.g.terminal_color_11 = "#c47033"
vim.g.terminal_color_12 = "#547c99"
vim.g.terminal_color_13 = "#9f4e85"
vim.g.terminal_color_14 = "#7dd6cf"
vim.g.terminal_color_15 = "#fdffb9"

