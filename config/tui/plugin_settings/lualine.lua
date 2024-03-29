local colors = {
--    black         = '#080808',
    grey          = '#4B5263',
    grey_inactive = '#3B4048'
}

local function modified()
    if vim.bo.modified then
        return "[+]"
    elseif vim.bo.modifiable == false or vim.bo.readonly == true then
        return "[-]"
    end
    return ""
end

local function count(base, pattern)
    return select(2, string.gsub(base, pattern, ''))
end

local function shorten_path(path, sep)
    -- ('([^/])[^/]+%/', '%1/', 1)
    return path:gsub(string.format('([^%s])[^%s]+%%%s', sep, sep, sep), '%1' .. sep, 1)
end

local filename = function()
    local nm = vim.fn.expand('%:p')
    if nm == "" then
        nm = "[No Name]"
    elseif vim.g.nvim_ide_project_root then
        local _, e = nm:find(vim.g.nvim_ide_real_project_root, 1, true)
        if e then
            local ind = e + 1
            if nm:sub(ind, ind) == "/" then
                ind = ind + 1
            end
            nm = nm:sub(ind)
        end
    end

    local shorting_target = 40
    local windwidth = vim.fn.winwidth(0)
    local estimated_space_available = windwidth - shorting_target
    local path_separator = '/'
    for _ = 0, count(nm, path_separator) do
        if windwidth <= 84 or #nm > estimated_space_available then
            nm = shorten_path(nm, path_separator)
        end
    end

    return modified() .. " " .. nm
end

local custom_gruvbox_material = require'lualine.themes.gruvbox-material'
custom_gruvbox_material.normal.b.bg = colors.grey
custom_gruvbox_material.insert.b.bg = colors.grey
custom_gruvbox_material.visual.b.bg = colors.grey
custom_gruvbox_material.normal.c.bg = colors.grey
custom_gruvbox_material.insert.c.bg = colors.grey
custom_gruvbox_material.visual.c.bg = colors.grey
custom_gruvbox_material.command.c.bg = colors.grey
custom_gruvbox_material.terminal.c.bg = colors.grey

custom_gruvbox_material.inactive.a.bg = colors.grey_inactive
custom_gruvbox_material.inactive.b.bg = colors.grey_inactive
custom_gruvbox_material.inactive.c.bg = colors.grey_inactive


require'lualine'.setup {
    options = {
        icons_enabled = vim.g.nvim_ide_allow_icons,
        theme = custom_gruvbox_material,
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {},
        always_divide_middle = true
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {},
        lualine_c = {filename},
        lualine_x = {"require'lsp-status'.status()"},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {filename},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    extensions = {'quickfix'}
}

