-- Utils
function exec_lsp_method(method, custom_handler)
    local util = require 'vim.lsp.util'
    local params = util.make_position_params()
    vim.lsp.buf_request(0, method, params, custom_handler)
end

local lsp_handlers = require("vim.lsp.handlers")
lsp_method_definition = 'textDocument/definition'
lsp_method_reference = 'textDocument/references'

lsp_definition_default_handler = lsp_handlers[lsp_method_definition]
lsp_reference_default_handler = lsp_handlers[lsp_method_reference]

function center_text(mode)
    special_symbol = ""
    if mode == "i" then
        special_symbol = vim.api.nvim_replace_termcodes("<C-o>", true, false, true)
    end
    vim.fn.feedkeys(special_symbol .. "zz")
end

-- LSP setup
local lspconfig = require('lspconfig')
local lsp_status = require('lsp-status')

lsp_status.config({
    current_function = false,
    show_filename = false,

    -- TODO: tune nvim-web-devicons and get rid of the following section
    indicator_errors = 'E',
    indicator_warnings = 'W',
    indicator_info = 'i',
    indicator_hint = '?',
    indicator_ok = 'Ok',
    status_symbol = ''
})

-- Common settings and maps
local opts = {noremap=true, silent=true}

-- vim.lsp.set_log_level("debug")

lsp_status.register_progress()
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        update_in_insert = true
    }
)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer

function show_definition(mode)
    exec_lsp_method(lsp_method_definition, function(err, result, ctx, config)
        lsp_definition_default_handler(err, result, ctx, config)
        center_text(mode)
    end)
end

function show_references()
    exec_lsp_method(lsp_method_reference, function(err, result, ctx, config)
        strToHl = vim.fn.expand("<cword>")
        lsp_reference_default_handler(err, result, ctx, config)
        if #vim.fn.getqflist() then
            vim.cmd("noh")
            vim.cmd("copen")
            vim.fn.clearmatches()

            ptrnLen = #strToHl
            for i, lItem in pairs(vim.fn.getqflist()) do
                vim.fn.matchaddpos("Search", {{i, #vim.fn.getline(i) - #lItem.text + lItem.col, ptrnLen}})
            end
        end
    end)
end

function goto_next_diagnostics(mode)
    vim.diagnostic.goto_next()
    center_text(mode)
end

function get_symbols(extSym)
    null_input_word = '___nvim_ide_null_input___'
    sym = vim.fn.input({prompt='Workspace symbol: ', default=extSym, cancelreturn=null_input_word})
    if sym == null_input_word then
        return 
    end

    if sym == "" then
        sym = vim.fn.expand("<cword>")
        vim.fn.histadd("input", sym)
    end

    if sym == "" then
        return
    end

    nvim_ide_workspace_symbol(0, sym)
end

local on_attach = function(client, bufnr)
    -- Maps
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<F2>', '<cmd>lua show_definition("n")<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'i', '<F2>', '<cmd>lua show_definition("i")<CR>', opts)

    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<F1>', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'i', '<F1>', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)

    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-l>', '<cmd>lua get_symbols("")<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'i', '<C-l>', '<C-o><cmd>lua get_symbols("")<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 's', '<C-l>', '<C-o>y<cmd>lua get_symbols(vim.fn.getreg())<CR>', opts)

    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-u>', '<cmd>lua show_references()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'i', '<C-u>', '<cmd>lua show_references()<CR>', opts)

    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-r>', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'i', '<C-r>', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<F4>', '<cmd>lua goto_next_diagnostics("n")<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'i', '<F4>', '<cmd>lua goto_next_diagnostics("i")<CR>', opts)

    -- 'lsp_signature' plugin initialized here. Otherwize (on standalone initialization) floating window not appear after multiple files editing and save.
    require("lsp_signature").on_attach({
        hint_enable = false,
        -- Default value "LspSignatureActiveParameter" is changed to "IncSearch" to highlight current parameter in each color scheme
        hi_parameter = "IncSearch",
        -- '<M-/>' key should be in sync with <Esc> mapping in 'editor' file
        toggle_key = "<M-/>"
    })

    -- Highlight symbol under cursor
    require('illuminate').on_attach(client)
    vim.cmd([[hi LspReferenceText cterm=underline gui=underline]])
    vim.cmd([[hi LspReferenceRead cterm=underline gui=underline]])
    vim.cmd([[hi LspReferenceWrite cterm=underline gui=underline]])
    vim.cmd([[autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()]])
    vim.cmd([[autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()]])
    vim.cmd([[autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()]])

    lsp_status.on_attach(client)
end

-- Server-specific settings

local servers = {
    gopls = {
        cmd = {"gopls", "serve"},
        settings = {
            gopls = {
                analyses = {
                    unusedparams = true,
                },
                staticcheck = true,
            }
        }
    }
}

if vim.g.nvim_ide_cpp_compilation_database_command then
--[[
    function GetCCLSCacheDir()
        return vim.fn["NvimIdeGetProjectExtraFilesDir"]() .. "/ccls-cache"
    end

    function GetCCLSInitialBlacklist()
        if vim.fn["empty"](vim.fn["glob"](GetCCLSCacheDir())) == 1 then
            return {}
        end

        return {"."}
    end

    servers["ccls"] = {
        init_options = {
            compilationDatabaseCommand = vim.g.nvim_ide_cpp_compilation_database_command,
            cache = {
                directory = GetCCLSCacheDir()
            },
            index = {
                onChange = true,
                -- Whole project should be reindexed on startup ony when ccls-cache dir is absent
                initialBlacklist = GetCCLSInitialBlacklist()
            },
            diagnostics = {
                onChange = 50
            },
            completion = {
                -- Disable snippets on confirmed completion (insert the name of selected function/variable without parameters)
                placeholder = false
            }
        }
    }
--]]

    local compile_commands_path = vim.g.nvim_ide_project_root .. "/compile_commands.json"
    vim.fn.system("cd " .. vim.g.nvim_ide_project_root .. "; " .. vim.g.nvim_ide_cpp_compilation_database_command .. " > " .. compile_commands_path)
    servers["clangd"] = {
        cmd = {"clangd", "--background-index", "--compile-commands-dir", vim.g.nvim_ide_project_root, "-j", vim.fn.string(vim.g.nvim_ide_cpp_language_server_threads)},
        filetypes = {"c", "cpp", "objc", "objcpp"},
    }
    -- TODO: try different --completion-style values
end

-- Set common settings and setup servers
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities = vim.tbl_extend('keep', capabilities, lsp_status.capabilities)
for lsp, settings in pairs(servers) do
    -- Common settings for all servers
    settings["on_attach"] = on_attach
    settings["flags"] = {
        -- This will be the default in neovim 0.7+
        debounce_text_changes = 150
    }
    settings["root_dir"] = function(nm)
        return vim.g["nvim_ide_project_root"] 
    end
    settings["capabilities"] = capabilities

    -- Setup final set of settings fo particular server
    lspconfig[lsp].setup(settings)
end
