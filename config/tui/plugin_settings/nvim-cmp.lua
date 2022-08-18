local cmp = require('cmp')

local function confirm(fallback)
    if cmp.visible() then
        cmp.confirm()
    else
        fallback()
    end
end

local function close(fallback)
    if cmp.visible() then
        cmp.close()
    else
        fallback()
    end
end

cmp.setup {
    completion = {
        -- Select first item automatically
        completeopt = 'menu,menuone,noinsert'
    },
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end
    },
    mapping = {
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
        ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
        ['<Tab>'] = cmp.mapping(confirm, { 'i', 'c' }),
        ['<Esc>'] = close
    },
    sources = {
        {name = 'nvim_lsp'},
        {name = 'nvim_lsp_signature_help'},
        {name = 'vsnip'}
    }
}

cmp.setup.cmdline(':', {
    sources = cmp.config.sources(
        {{
            name = 'path'
        }},
        {{
            name = 'cmdline'
        }}
    )
})

