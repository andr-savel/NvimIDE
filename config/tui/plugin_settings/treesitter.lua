local parsers = { "c", "cpp", "go", "python", "lua", "vim", "vimdoc", "markdown" }
local ts = require('nvim-treesitter')

ts.setup({
  -- The only major option now is often just the install directory
  -- Highlighting is typically ON by default in 0.12 for core languages
})

-- To manually install parsers
ts.install(parsers)

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("TreesitterSetup", {clear = true}),
    callback = function()
        -- switch-on highlight
        local ok, _ = pcall(vim.treesitter.start)

        -- switch-on indents
        if ok then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

