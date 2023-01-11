----------------------- dap config
local dap = require('dap')
local lldbVscodePath = vim.fn.exepath("lldb-vscode")
dap.adapters.lldb = {
    type = 'executable',
    command = lldbVscodePath,
    name = 'lldb'
}

local configCppLaunch = {
    name = 'Launch C++',
    type = 'lldb',
    request = 'launch',
    program = vim.g.nvim_ide_debuggee_binary_path,
    args = vim.g.nvim_ide_debuggee_binary_args,
    stopOnEntry = false
}

local function GetConfigCppAttach(procId) 
    return {
        -- If you get an "Operation not permitted" error using this, try disabling YAMA:
        --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
        name = "Attach C++",
        type = 'lldb',
        request = 'attach',
        pid = procId,
        args = {},
    }
end

local function GetConfigCppCoreFile(pathToCoreFile)
    return {
        name = "Load C++ core file",
        type = "lldb",
        request = "attach",
        program = vim.g.nvim_ide_debuggee_binary_path,
        coreFile = pathToCoreFile
    }
end

dap.defaults.fallback.exception_breakpoints = {'cpp_throw'}

local function IsLldbVscodeFileType()
    return vim.bo.filetype == "cpp" or vim.bo.filetype == "c" or vim.bo.filetype == "objc" or vim.bo.filetype == "rust"
end

local function GetLaunchConfig()
    if IsLldbVscodeFileType() then
        return configCppLaunch
    end
end

local function GetAttachConfig(procId)
    if IsLldbVscodeFileType() then
        return GetConfigCppAttach(procId)
    end
end

local function GetCoreFileConfig(pathToCoreFile)
    if IsLldbVscodeFileType() then
        return GetConfigCppCoreFile(pathToCoreFile)
    end
end


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
            vim.g.nvim_ide_debuggee_binary_args = vim.fn.split(inp)
        end
    end)

    -- TODO: it is used to clear command line content. Should be used something more suitable.
    vim.cmd('normal! /')
end

local function RunDebug(config)
    if #vim.g.nvim_ide_debuggee_binary_path == 0 then
        SetDbgParams()
    end

    StartGdbPreActions()
    dap.run(config)
end

vim.keymap.set({'n', 'i'}, '<f5>', function()
    if dap.session() then
        dap.continue()
        return
    end

    lc = GetLaunchConfig()
    if lc then
        RunDebug(lc)
    end
end)

function NvimIdeAttachToProcess(procId)
    ac = GetAttachConfig(procId)
    if ac then
        RunDebug(ac)
    end
end

vim.cmd[[
function! NvimIdeSelectPidAndAttach(isInsertMode)
    function! AttachToProc(line)
        let arr = split(a:line) 
        if len(arr) > 0
            call luaeval('NvimIdeAttachToProcess(_A)', str2nr(arr[0]))
        endif    
    endfunction      
    let binName = fnamemodify(g:nvim_ide_debuggee_binary_path, ':t')
    call fzf#run(fzf#wrap({'source': 'ps -u ' . $USER . ' -eo "%p   %a" --no-headers | grep -v "query=' . binName . '"',
                                   \ 'options': ' --prompt="Processes> "' .
                                   \            ' --info=inline' .
                                   \            ' --query=' . binName,
                                   \ 'sink': function('AttachToProc')}))

    if a:isInsertMode
        call feedkeys('i', 'n')
    endif
endfunction
]]

local function AttachImpl(isInsertMode)
    pids = vim.fn.split(vim.fn.system("pidof " .. vim.g.nvim_ide_debuggee_binary_path))
    pidsLen = #pids
    if pidsLen == 0 then
        vim.api.nvim_err_writeln("NvimIde: cannot find running process '" .. vim.g.nvim_ide_debuggee_binary_path .. "'")
        return
    elseif pidsLen == 1 then
        NvimIdeAttachToProcess(vim.fn.str2nr(pids[1]))
        return
    end

    if isInsertMode then
        vim.cmd("stopinsert")
        vim.cmd('call NvimIdeSelectPidAndAttach(v:true)')
    else
        vim.cmd('call NvimIdeSelectPidAndAttach(v:false)')
    end
end

vim.keymap.set({'n'}, '<M-a>', function()
    AttachImpl(false)
end)
vim.keymap.set({'i'}, '<M-a>', function()
    AttachImpl(true)
end)

vim.keymap.set({'n', 'i'}, '<f6>', function()
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

vim.api.nvim_create_user_command('NvimIdeSetCondBP', function()
    dap.set_breakpoint(vim.fn.input('Enter condition expression: '))
end, {})

vim.api.nvim_create_user_command('NvimIdeSetDbgParams', SetDbgParams, {})

vim.api.nvim_create_user_command('NvimIdeOpenCoreFile', function ()
    pathToCore = vim.fn.input('Path to core file: ')
    cc = GetCoreFileConfig(pathToCore)
    if cc then
        RunDebug(cc)
    end 
end, {})

