----------------------- dap config
local dap = require('dap')
local lldbVscodePath = vim.fn.exepath("lldb-vscode")
dap.adapters.lldb = {
    type = 'executable',
    command = lldbVscodePath,
    name = 'lldb'
}

local configCppLaunch = {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = vim.g.nvim_ide_debuggee_binary_path,
    args = vim.g.nvim_ide_debuggee_binary_args,
    stopOnEntry = false
}

dap.configurations.cpp = {
    configCppLaunch,
}
dap.defaults.fallback.exception_breakpoints = {'cpp_throw'}

dap.configurations.c = dap.configurations.cpp


----------------------- dap-ui config
local dapui = require('dapui')
dapui.setup({
    icons = {expanded = "", collapsed = "", current_frame = ""},
    mappings = {
        -- Use a table to apply multiple mappings
        expand = {},
        open = {},
        remove = {},
        toggle = {},
        edit = "e",
        repl = "r"
    },
    -- Use this to override mappings for specific elements
    element_mappings = {
        -- Example:
        stacks = {
            open = {"<CR>", "<2-LeftMouse>"}
        },
        breakpoints = {
            open = {"<CR>", "<2-LeftMouse>"},
            toggle = "<f9>"
        },
        watches = {
            expand = {"<CR>", "<2-LeftMouse>", "<Space>"},
            remove = "<Del>"
        },
        scopes = {
            expand = {"<CR>", "<2-LeftMouse>", "<Space>"}
        },
        hover = {
            expand = {"<CR>", "<2-LeftMouse>", "<Space>"}
        }
    },
    expand_lines = false, -- Expand lines larger than the window
    layouts = {
        {
            elements = {
                "repl",
--                "console",
                "stacks"
            },
            size = 0.27,
            position = "bottom",
        },
        {
            elements = {
                "breakpoints",
                {id = "watches", size = 0.30},
                {id = "scopes", size = 0.50}
            },
            size = 0.5,
            position = "right",
        },
    },
    controls = {
        enabled = false,
    },
    floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = "single", -- Border style. Can be "single", "double" or "rounded"
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    windows = { indent = 1 },
    render = {
        max_type_length = nil, -- Can be integer or nil.
        max_value_lines = 100, -- Can be integer or nil.
    }
})

if vim.g.nvim_ide_allow_icons then
    vim.fn.sign_define('DapBreakpoint', {text ='', texthl ='LspDiagnosticsSignError', linehl ='', numhl =''})
    vim.fn.sign_define('DapBreakpointCondition', {text ='', texthl ='LspDiagnosticsSignError', linehl ='', numhl =''})
    vim.fn.sign_define("DapStopped", {text ='', texthl = "TSNote", linehl = "", numhl = "TSNote"})
end

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open({reset = true})
end

local function StartGdbPreActions()
    vim.cmd('tab sb')
    vim.cmd('stopinsert')
    vim.opt_local.scrolloff = 10
end

local function StopDbgPreActions()
    dapui.close()
    dap.repl.close()
end

local function StopDbgPostActions()
    vim.cmd('startinsert')
    vim.cmd('tabclose')
end

dap.listeners.before.event_terminated["dapui_config"] = StopDbgPreActions
dap.listeners.after.event_terminated["dapui_config"] = StopDbgPostActions

dap.listeners.before.event_exited["dapui_config"] = StopDbgPreActions

local function SetDbgParams()
    vim.ui.input({prompt = 'Debug program path: ', default = vim.g.nvim_ide_debuggee_binary_path}, function(inp)
        if inp then
            vim.g.nvim_ide_debuggee_binary_path = inp
        end
    end)

    vim.ui.input({prompt = 'Debug program args: ', default = table.concat(vim.g.nvim_ide_debuggee_binary_args, ' ')}, function(inp)
        if inp then
            vim.g.nvim_ide_debuggee_binary_args = vim.split(inp, ' ')
        end
    end)

    -- TODO: it is used to clear command line content. Should be used something more suitable.
    vim.cmd('normal! /')
end

local function IsLldbVscodeFileType()
    return vim.bo.filetype == "cpp" or vim.bo.filetype == "c" or vim.bo.filetype == "objc" or vim.bo.filetype == "rust"
end 

vim.keymap.set({'n', 'i', 's'}, '<f5>', function()
    if dap.session() then
        dap.continue()
        return
    end

    if #vim.g.nvim_ide_debuggee_binary_path == 0 then
        SetDbgParams()
    end

    StartGdbPreActions()

    if IsLldbVscodeFileType() then
        dap.run(configCppLaunch)
    end
end)

vim.keymap.set({'n', 'i', 's'}, '<f6>', function()
    if dap.session() then
        dap.terminate()
    else
        StopDbgPreActions()
    end 
end)

vim.keymap.set({'n', 'i', 's'}, '<f10>', function()
    dap.step_over()
end)

vim.keymap.set({'n', 'i', 's'}, '<f11>', function()
    dap.step_into()
end)

vim.keymap.set({'n', 'i', 's'}, '<f12>', function()
    dap.step_out()
end)

vim.keymap.set({'n', 'i', 's'}, '<f9>', function()
    dap.toggle_breakpoint()
end)

vim.keymap.set({'n', 'v'}, '<C-e>', function()
    dapui.eval()
end)

vim.api.nvim_create_user_command('NvimIdeSetCondBP', dap.set_breakpoint(vim.fn.input('Enter condition expression: ')), {})
vim.api.nvim_create_user_command('NvimIdeSetDbgParams', SetDbgParams, {})

