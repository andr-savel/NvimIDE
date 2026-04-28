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

local signs = {}

if vim.g.nvim_ide_allow_icons then
    signs = {
        error = '',
        warn = '',
        info = '',
        hint = ''
    }
else
    signs = {
        error = 'E',
        warn = 'W',
        info = 'i',
        hint = 'h'
    }
end

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = signs.error,
            [vim.diagnostic.severity.WARN]  = signs.warn,
            [vim.diagnostic.severity.HINT]  = signs.hint,
            [vim.diagnostic.severity.INFO]  = signs.info,
        },
    },
    update_in_insert = true,
    severity_sort = true,
})

require('lsp-progress').setup({
    decay = 1000,
    format = function(client_messages)
        local clients = vim.lsp.get_clients({bufnr = 0})
        local client_names = {}
        
        for _, client in ipairs(clients) do
            local message = nil
            for _, msg in ipairs(client_messages) do
                if msg:find("%[" .. client.name .. "%]") then
                    message = msg
                    break
                end
            end

            if message then
                table.insert(client_names, message)
            else
                table.insert(client_names, "[" .. client.name .. "]")
            end
        end

        if #client_names == 0 then
            return ""
        end

        return table.concat(client_names, " ")
    end,
    client_format = function(client_name, spinner, series_messages)
        local ret = "[" .. client_name .. "]";
        if #series_messages > 0 then
            ret = ret .. " " .. spinner .. " " .. table.concat(series_messages, ", ")
        end
        return ret
    end,
    done_icon = ""
})

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
        lualine_x = {
            {
                'diagnostics',
                symbols = {
                    error = signs.error .. ' ',
                    warn = signs.warn .. ' ',
                    info = signs.info .. ' ',
                    hint = signs.hint .. ' '
                },
                diagnostics_color = {
                    error = {gui = 'bold'},
                    warn  = {gui = 'bold'},
                    info  = {gui = 'bold'},
                    hint  = {gui = 'bold'},
                },
                update_in_insert = true,
            },
            {
                function()
                    return require('lsp-progress').progress()
                end,
            },
        },
        lualine_y = {},
        lualine_z = {
            'location',
            'progress'
        }
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

