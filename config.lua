-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny


-- Disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

local is_windows = vim.fn.has("win32") == 1

if is_windows then
    -- Enable powershell as your default shell
    vim.opt.shell = "pwsh.exe"
    vim.opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.cmd [[
    let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    set shellquote= shellxquote=
]]

    -- Set a compatible clipboard manager
    vim.g.clipboard = {
        copy = {
            ["+"] = "win32yank.exe -i --crlf",
            ["*"] = "win32yank.exe -i --crlf",
        },
        paste = {
            ["+"] = "win32yank.exe -o --lf",
            ["*"] = "win32yank.exe -o --lf",
        },
    }
end
-- Undo/backup
vim.opt.undofile = true
vim.opt.backup = true
vim.opt.backupdir = vim.fn.stdpath("data") .. "/backup"
-- vim.opt.swapfile = true

-- Spacing
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.wrap = true

-- Options from old .vimrc
vim.opt.ruler = true
vim.opt.lazyredraw = false
vim.opt.foldcolumn = "1"
vim.opt.showcmd = true

-- Delete trailing space on save
local function clean_extra_space()
    local save_cursor = vim.fn.getpos(".")
    local old_query = vim.fn.getreg('/')
    vim.cmd([[silent! %s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
    vim.fn.setreg('/', old_query)
end

lvim.autocommands = {
    {
        "BufWritePre",
        {
            pattern = { "*.txt", "*.js", "*.py", "*.wiki", "*.sh", "*.coffee", "*.ts" },
            callback = clean_extra_space
        }
    }
}

lvim.plugins = {
    { "lukas-reineke/indent-blankline.nvim", enabled = false, },
    {
        "hiphish/rainbow-delimiters.nvim",
        enabled = false,
    },
    { "nvim-tree/nvim-web-devicons",         opts = {} },
    -- v3 requires nvim 0.11+; pin to last v2 release until nvim is upgraded
    { 'mrjones2014/smart-splits.nvim', tag = "v2.1.1-final" },
    { "nvim-treesitter/nvim-treesitter" },
    { "shortcuts/no-neck-pain.nvim",         version = "*" },
    {
        "windwp/nvim-ts-autotag",
        config = function()
            require("nvim-ts-autotag").setup()
        end,
    },
    {
        "rmagatti/goto-preview",
        config = function()
            require('goto-preview').setup {
                width = 120,              -- Width of the floating window
                height = 25,              -- Height of the floating window
                default_mappings = false, -- Bind default mappings
                debug = false,            -- Print debug information
                opacity = nil,            -- 0-100 opacity level of the floating window where 100 is fully transparent.
                post_open_hook = nil      -- A function taking two arguments, a buffer and a window to be ran as a hook.
                -- You can use "default_mappings = true" setup option
                -- Or explicitly set keybindings
                -- vim.cmd("nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>")
                -- vim.cmd("nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>")
                -- vim.cmd("nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>")
            }
        end
    },
    {
        "ray-x/lsp_signature.nvim",
        -- newer commits use the nvim 0.11 str_utfindex signature; pin until nvim is upgraded
        commit = "af7e4074d85d785cf6614352ba9ad3b28a1f8a56",
        event = "InsertEnter",
        opts = {
            bind = true,
            handler_opts = {
                border = "rounded",
            },
        },
    },
    {
        "ethanholz/nvim-lastplace",
        event = "BufRead",
        config = function()
            require("nvim-lastplace").setup({
                lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
                lastplace_ignore_filetype = {
                    "gitcommit", "gitrebase", "svn", "hgcommit",
                },
                lastplace_open_folds = true,
            })
        end,
    },
    {
        "folke/persistence.nvim",
        event = "BufReadPre", -- this will only start session saving when an actual file was opened
        lazy = true,
        config = function()
            require("persistence").setup {
                dir = vim.fn.expand(vim.fn.stdpath "config" .. "/session/"),
                options = { "buffers", "curdir", "tabpages", "winsize" },
            }
        end,
    },
    {
        "folke/todo-comments.nvim",
        event = "BufRead",
        config = function()
            require("todo-comments").setup()
        end,
    },
    {
        "esmuellert/nvim-eslint",
        config = function()
            require("nvim-eslint").setup({})
        end,
    },
    { "pixelastic/vim-undodir-tree" },
    {
        "folke/trouble.nvim",
        opts = {},
        cmd = "Trouble",
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
    },
    { "nvim-neotest/neotest-jest" },
    -- { "rcarriga/nvim-notify" },
    -- { "MunifTanjim/nui.nvim" },
    -- {
    --     "folke/noice.nvim",
    --     event = "VeryLazy",
    --     dependencies = {
    --         "MunifTanjim/nui.nvim",
    --         "rcarriga/nvim-notify",
    --     },
    -- }
    {
        "mfukar/robotframework-vim",
        ft = "robot",
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    {
        "akinsho/toggleterm.nvim",
    },
    { "catppuccin/nvim",        name = "catppuccin", priority = 1000 },
    -- {
    --     "dense-analysis/ale",
    --     config = function()
    --         local g = vim.g
    --         g.ale_disable_lsp = 1
    --         g.ale_linters = {
    --             javascript = { "eslint" },
    --             sh = { "shellcheck" },
    --         }
    --     end
    -- },
    { "nvim-mini/mini.comment", version = false },
    { "numToStr/Comment.nvim",  enabled = false },
    {
        "hat0uma/csvview.nvim",
        ---@module "csvview"
        ---@type CsvView.Options
        opts = {
            parser = {
                comments = { "#", "//" },
                delimiter = {
                    ft = {
                        csv = ",", -- Always use comma for .csv files
                        tsv = "\t", -- Always use tab for .tsv files
                    },
                    fallbacks = { -- Try these delimiters in order for other files
                        ",",    -- Comma (most common)
                        "\t",   -- Tab
                        ";",    -- Semicolon
                        "|",    -- Pipe
                        ":",    -- Colon
                        " ",    -- Space
                    },
                },
            },
            keymaps = {
                -- Text objects for selecting fields
                textobject_field_inner = { "if", mode = { "o", "x" } },
                textobject_field_outer = { "af", mode = { "o", "x" } },
                -- Excel-like navigation:
                -- Use <Tab> and <S-Tab> to move horizontally between fields.
                -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
                -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
                jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
                jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
                jump_next_row = { "<Enter>", mode = { "n", "v" } },
                jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
            },
            view = {
                header_lnum = true, -- Auto-detect header (default)
                sticky_header = {
                    enabled = true,
                    separator = "─", -- Separator line character
                },
            },
        },
        cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
    },
}

-- Returns the trimmed stdout of a command, or nil if it is missing or fails
local function cmd_output(cmd)
    if vim.fn.executable(cmd[1]) ~= 1 then
        return nil
    end
    local out = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
        return nil
    end
    return vim.trim(out)
end

local function system_is_dark()
    if vim.fn.has("mac") == 1 then
        -- prints "Dark" in dark mode; exits non-zero (key missing) in light mode
        local out = cmd_output({ "defaults", "read", "-g", "AppleInterfaceStyle" })
        return out ~= nil and out:match("Dark") ~= nil
    elseif vim.fn.has("unix") == 1 then
        -- Cinnamon (Mint). The keys don't exist on other desktops, so the commands fail
        -- and this falls through to light. org.gnome.desktop.interface color-scheme is
        -- deliberately not used: on Mint it stays 'prefer-dark' even in light mode.
        local scheme = cmd_output({ "gsettings", "get", "org.x.apps.portal", "color-scheme" })
        if scheme and scheme:match("prefer%-dark") then
            return true
        end
        -- Otherwise infer from the GTK theme name, e.g. 'Mint-L-Dark-Blue'
        local theme = cmd_output({ "gsettings", "get", "org.cinnamon.desktop.interface", "gtk-theme" })
        return theme ~= nil and theme:lower():match("dark") ~= nil
    end
    return false
end

-- Follow the system appearance: macchiato in dark mode, latte in light mode.
-- Detected on macOS and Linux Mint (Cinnamon); anything else falls back to latte.
local function system_colorscheme()
    return system_is_dark() and "catppuccin-macchiato" or "catppuccin-latte"
end

lvim.colorscheme = system_colorscheme()

-- Re-check when nvim regains focus so a system switch is picked up without a restart
vim.api.nvim_create_autocmd("FocusGained", {
    callback = function()
        local scheme = system_colorscheme()
        if scheme ~= vim.g.colors_name then
            vim.cmd.colorscheme(scheme)
        end
    end,
})

-- CsvView
local csv_group = vim.api.nvim_create_augroup("CsvViewAutoEnable", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = csv_group,
    pattern = { "csv", "tsv" },
    callback = function()
        require("csvview").enable()
    end,
})

-- Comments
local mini_comment = require("mini.comment")
mini_comment.setup({
    mappings = {
        comment = '',
        comment_line = '',
        comment_visual = '',
        textobject = '',
    },
})

lvim.builtin.which_key.mappings['/'] = {
    "<cmd>lua require('mini.comment').toggle_lines(vim.fn.getcurpos('.')[2], vim.fn.getcurpos('.')[2])<cr>",
    "Toggle Comment"
}

-- Noice
-- require("noice").setup({
--     lsp = {
--         override = {

--             ["cmp.entry.get_documentation"] = true,
--         },
--     },
--     presets = {
--         bottom_search = true,
--         command_palette = true,
--         long_message_to_split = true,
--         inc_rename = false,
--         lsp_doc_border = false,
--     },
-- })

-- Notify
-- require("notify").setup({
--     render = "wrapped-default",
--     timeout = 3000,
-- })
-- vim.notify = require("notify")

-- Neotest
require("neotest").setup({
    adapters = {
        require("neotest-jest")({
            jestCommand = "npm test --"
        }),
    },
})

lvim.builtin.which_key.mappings["t"] = {
    name = "Test",
    r = { "<cmd>lua require('neotest').run.run()<cr>", "Run" },
    R = { "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", "Run (file)" },
    s = { "<cmd>lua require('neotest').run.stop()<cr>", "Stop" },
    d = { "<cmd>lua require('neotest').run.run({strategy='dap'})<cr>", "Debug" },
    o = { "<cmd>Neotest output-panel<cr>", "Output Window" },
    O = { "<cmd>Neotest summary<cr>", "Summary Window" },
}

lvim.builtin.which_key.mappings["S"] = {
    name = "Session",
    c = { "<cmd>lua require('persistence').load()<cr>", "Restore last session for current dir" },
    l = { "<cmd>lua require('persistence').load({ last = true })<cr>", "Restore last session" },
    Q = { "<cmd>lua require('persistence').stop()<cr>", "Quit without saving session" },
}

lvim.builtin.which_key.mappings["x"] = {
    name = "Trouble",
    x = { "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Diagnostics" },
    X = { "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics (workspace)" },
    o = { "<cmd>Trouble symbols toggle focus=false<cr>", "Symbols" }
}

-- lvim.lsp.on_attach_callback = function(client, bufnr)
-- require"lsp_signature".on_attach()
-- end

-- No neck pain

-- Side buffer color per colorscheme, taken from the catppuccin palette:
-- latte uses the next darker step from base (mantle), macchiato the next lighter (surface0).
local function get_background()
    local palettes = require("catppuccin.palettes")
    local scheme = vim.g.colors_name or ""
    if scheme == "catppuccin-latte" then
        return palettes.get_palette("latte").mantle
    elseif scheme == "catppuccin-macchiato" then
        return palettes.get_palette("macchiato").surface0
    end
    -- other schemes: fall back to the theme background (no visible margins)
    local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
    return bg and string.format("#%06x", bg) or nil
end

-- no-neck-pain mutates the opts table it is given (it caches per-side
-- colors in it), so rebuild the buffers section on every colorscheme change.
local function nnp_buffers()
    return {
        colors = {
            background = get_background(),
        },
    }
end

local nnp_opts = {
    -- 50% the width of the monitor
    -- Ultrawide: 3440 / 2 = 1720
    -- Standard: 1920 / 2 = 960
    --
    -- The documentation is unclear, but the value of "width" might represent the number of characters, not pixels.
    -- The width of a font is usually estimated to be 1.09 times the height of the font (e.g., 12).
    -- (of course, font height is measured in points (pt), not pixels...)
    --
    -- The average width of Cascadia Mono NF is 9.38 chars, so if we want to display 127 chars it would be the multiple.
    width = 167,
    autocmds = {
        enableOnVimEnter = 'safe',
    },
    buffers = nnp_buffers(),
}

require('no-neck-pain').setup(nnp_opts)

-- Runs before the plugin's own (scheduled) reload, which reuses nnp_opts.
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        nnp_opts.buffers = nnp_buffers()
        -- keep the live config current too, so enabling later uses the right color
        if _G.NoNeckPain and _G.NoNeckPain.config then
            _G.NoNeckPain.config = require('no-neck-pain.config').defaults(vim.deepcopy(nnp_opts))
        end
        -- Queued after the plugin's own scheduled reload. That reload only updates its
        -- config; existing side windows keep their old highlights, so repaint them.
        vim.schedule(function()
            if _G.NoNeckPain == nil or _G.NoNeckPain.state == nil or not _G.NoNeckPain.state.enabled then
                return
            end
            local state = require('no-neck-pain.state')
            for _, side in ipairs({ "left", "right" }) do
                require('no-neck-pain.colors').init(state:get_side_id(side), side)
            end
        end)
    end,
})

lvim.builtin.treesitter.rainbow.enable = true

lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.view.width = 30

vim.g.rainbow_delimiters = {
    blacklist = { 'markdown', 'nofile', 'prompt' },
}

-- LSP configs --
local lspconfig = require("lspconfig")

lspconfig.angularls.setup {
    filetypes = { 'typescript', 'html', 'typescriptreact', 'typescript.tsx', 'htmlangular', },
}

lspconfig.groovyls.setup({
    capabilities = (function()
        local caps = vim.lsp.protocol.make_client_capabilities()
        caps.general = caps.general or {}
        caps.general.positionEncodings = { 'utf-16' }
        return caps
    end)(),
})
-- vim.lsp.enable("robotframework_ls")

-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "autotools-language-server" })



-- Smart splits
lvim.keys.normal_mode["<M-S-Left>"] = require("smart-splits").resize_left
lvim.keys.normal_mode["<M-S-Right>"] = require("smart-splits").resize_right
lvim.keys.normal_mode["<M-S-Up>"] = require("smart-splits").resize_up
lvim.keys.normal_mode["<M-S-Down>"] = require("smart-splits").resize_down

lvim.keys.normal_mode["<S-Left>"] = require("smart-splits").move_cursor_left
lvim.keys.normal_mode["<S-Right>"] = require("smart-splits").move_cursor_right
lvim.keys.normal_mode["<S-Up>"] = require("smart-splits").move_cursor_up
lvim.keys.normal_mode["<S-Down>"] = require("smart-splits").move_cursor_down

-- Statusline

-- Paste mode indicator
local function has_paste()
    if vim.o.paste then
        return "PASTE MODE"
    end
    return ""
end

local components = require("lvim.core.lualine.components")
lvim.builtin.lualine.sections.lualine_a = { has_paste, "mode" }
lvim.builtin.lualine.sections.lualine_b = {
    {
        "branch",
        fmt = function(str)
            -- Only show last characters of the branch if too long
            return str:sub(-48)
        end,
    },
    components.diff,
}
lvim.builtin.lualine.sections.lualine_c = {
    {
        "filename",
        file_status = true,
        newfile_status = true,
        path = 2,
        symbols = {
            modified = '[*]',
            readonly = '[READONLY]',
        },
    },
}
-- lvim.builtin.lualine.sections.lualine_x = { components.diagnostics, components.filetype, components.lsp }
-- lvim.builtin.lualine.sections.lualine_y = { components.progress }
-- lvim.builtin.lualine.sections.lualine_z = { components.location }

-- Other bindings
local function organize_imports()
    local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
        title = ""
    }
    vim.lsp.buf.execute_command(params)
end
lspconfig.tsserver.setup {
    commands = {
        OrganizeImports = {
            organize_imports,
            description = "Organize Imports",
        },
    },
}

lvim.builtin.which_key.mappings["l"] = {
    name = "LSP",
    a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
    d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Go to Definition" },
    D = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Go to Declaration" },
    f = { "<cmd>lua require('lvim.lsp.utils').format()<cr>", "Format" },
    h = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Show Hover" },
    I = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Go to Implementation" },
    o = { "<cmd>Telescope lsp_document_symbols<cr>", "Symbols" },
    r = { "<cmd>lua vim.lsp.buf.references()<cr>", "Go to References" },
    R = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
    x = { "<cmd>lua vim.diagnostic.open_float()<cr>", "Show Line Diagnostics" },
}

lvim.builtin.which_key.mappings["r"] = {
    "<cmd>Telescope find_files<cr>", "Find Files"
}
lvim.builtin.which_key.mappings["f"] = {
    "/", "Find"
}
lvim.keys.normal_mode["<M-Left>"] = "<cmd>BufferLineCyclePrev<CR>"
lvim.keys.normal_mode["<M-Right>"] = "<cmd>BufferLineCycleNext<CR>"

-- Annoyingly unable to disable treesitter configs the proper way
table.insert(lvim.autocommands, {
    "BufEnter",
    {
        command = "silent! TSDisable indent",
    },
})
-- vim.api.nvim_create_autocmd("BufEnter", {
--     pattern = { "*.robot" },
--     callback = function()
--         pcall(vim.treesitter.stop, 0)
--     end
-- })
-- vim.api.nvim_create_autocmd("BufEnter", {
--     command = "silent! TSDisable indent",
-- })


require("nvim-treesitter.configs").setup({
    highlight = {
        enable = true,
        disable = { "robot" },
    },
})

local formatters = require 'lvim.lsp.null-ls.formatters'
formatters.setup({
    {
        name = 'prettier',
        filetypes = {
            'typescript',
            'typescriptreact',
            'javascript',
            'javascriptreact',
            'json',
            'html',
            'css',
        },
    },
})

vim.api.nvim_exec2("command W :execute ':silent w !sudo tee % > /dev/null' | edit!", {})
