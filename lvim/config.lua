-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Keybinding Configuration
lvim.keys.normal_mode["|"] = ":vsplit<CR>"
lvim.keys.normal_mode["-"] = ":split<CR>"

-- Setting tabbing to 4 spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Rust Configuration
-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
    "lua",
    "rust",
    "toml",
}

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "rust_analyzer" })

local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")

local codelldb_path = mason_path .. "bin/codelldb"
local liblldb_path = mason_path .. "packages/codelldb/extension/lldb/lib/liblldb"
local this_os = vim.loop.os_uname().sysname

-- The path in windows is different
if this_os:find "Windows" then
    codelldb_path = mason_path .. "packages\\codelldb\\extension\\adapter\\codelldb.exe"
    liblldb_path = mason_path .. "packages\\codelldb\\extension\\lldb\\bin\\liblldb.dll"
else
    -- The liblldb extension is .so for linux and .dylib for macOS
    liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
end

pcall(function()
    require("rust-tools").setup {
        tools = {
            executor = require("rust-tools/executors").termopen, -- can be quickfix or termopen
            reload_workspace_from_cargo_toml = true,
            runnables = {
                use_telescope = true,
            },
            inlay_hints = {
                auto = true,
                only_current_line = false,
                show_parameter_hints = false,
                parameter_hints_prefix = "<-",
                other_hints_prefix = "=>",
                max_len_align = false,
                max_len_align_padding = 1,
                right_align = false,
                right_align_padding = 7,
                highlight = "Comment",
            },
            hover_actions = {
                border = "rounded",
            },
            on_initialized = function()
                vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "CursorHold", "InsertLeave" }, {
                    pattern = { "*.rs" },
                    callback = function()
                        local _, _ = pcall(vim.lsp.codelens.refresh)
                    end,
                })
            end,
        },
        dap = {
            -- adapter= codelldb_adapter,
            adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
        },
        server = {
            on_attach = function(client, bufnr)
                require("lvim.lsp").common_on_attach(client, bufnr)
                local rt = require "rust-tools"
                vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
            end,

            capabilities = require("lvim.lsp").common_capabilities(),
            settings = {
                ["rust-analyzer"] = {
                    lens = {
                        enable = true,
                    },
                    checkOnSave = {
                        enable = true,
                        command = "clippy",
                    },
                },
            },
        },
    }
end)

lvim.builtin.dap.on_config_done = function(dap)
    dap.adapters.codelldb = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
    dap.configurations.rust = {
        {
            name = "Launch file",
            type = "codelldb",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
    }
end

vim.api.nvim_set_keymap("n", "<m-d>", "<cmd>RustOpenExternalDocs<Cr>", { noremap = true, silent = true })

lvim.builtin.which_key.mappings["C"] = {
    name = "Rust",
    r = { "<cmd>RustRunnables<Cr>", "Runnables" },
    t = { "<cmd>lua _CARGO_TEST()<cr>", "Cargo Test" },
    m = { "<cmd>RustExpandMacro<Cr>", "Expand Macro" },
    c = { "<cmd>RustOpenCargo<Cr>", "Open Cargo" },
    p = { "<cmd>RustParentModule<Cr>", "Parent Module" },
    d = { "<cmd>RustDebuggables<Cr>", "Debuggables" },
    v = { "<cmd>RustViewCrateGraph<Cr>", "View Crate Graph" },
    R = {
        "<cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<Cr>",
        "Reload Workspace",
    },
    o = { "<cmd>RustOpenExternalDocs<Cr>", "Open External Docs" },
    y = { "<cmd>lua require'crates'.open_repository()<cr>", "[crates] open repository" },
    P = { "<cmd>lua require'crates'.show_popup()<cr>", "[crates] show popup" },
    i = { "<cmd>lua require'crates'.show_crate_popup()<cr>", "[crates] show info" },
    f = { "<cmd>lua require'crates'.show_features_popup()<cr>", "[crates] show features" },
    D = { "<cmd>lua require'crates'.show_dependencies_popup()<cr>", "[crates] show dependencies" },
}


-- Python Configuration
-- Flask Run
vim.api.nvim_create_user_command("FlaskRun", "split | term flask run", {})

-- install plugins
lvim.plugins = {
    "ChristianChiarulli/swenv.nvim",
    "stevearc/dressing.nvim",
    "mfussenegger/nvim-dap-python",
    "nvim-neotest/nvim-nio",
    "nvim-neotest/neotest",
    "nvim-neotest/neotest-python",
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
        { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    },
    "simrat39/rust-tools.nvim",
    {
        "saecki/crates.nvim",
        version = "v0.3.0",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("crates").setup {
                null_ls = {
                    enabled = true,
                    name = "crates.nvim",
                },
                popup = {
                    border = "rounded",
                },
            }
        end,
    },
    {
        "j-hui/fidget.nvim",
        config = function()
            require("fidget").setup()
        end,
    },
    "HiPhish/rainbow-delimiters.nvim",
}

-- automatically install python syntax highlighting
lvim.builtin.treesitter.ensure_installed = {
    "python",
}

-- setup formatting
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup { { name = "black" }, }
lvim.format_on_save.enabled = true
lvim.format_on_save.pattern = { "*.py" }

-- setup linting
local linters = require "lvim.lsp.null-ls.linters"
linters.setup { { command = "flake8", filetypes = { "python" } } }

-- setup debug adapter
lvim.builtin.dap.active = true
local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
pcall(function()
    require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python")
end)

-- setup testing
require("neotest").setup({
    adapters = {
        require("neotest-python")({
            -- Extra arguments for nvim-dap configuration
            -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
            dap = {
                justMyCode = false,
                console = "integratedTerminal",
            },
            args = { "--log-level", "DEBUG", "--quiet" },
            runner = "pytest",
        })
    }
})

lvim.builtin.which_key.mappings["dm"] = { "<cmd>lua require('neotest').run.run()<cr>",
    "Test Method" }
lvim.builtin.which_key.mappings["dM"] = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",
    "Test Method DAP" }
lvim.builtin.which_key.mappings["df"] = {
    "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>", "Test Class" }
lvim.builtin.which_key.mappings["dF"] = {
    "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", "Test Class DAP" }
lvim.builtin.which_key.mappings["dS"] = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Test Summary" }


-- binding for switching
lvim.builtin.which_key.mappings["C"] = {
    name = "Python",
    c = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Choose Env" },
}

-- HTML Configuration [For Future Implementation]
