return {
    -- Follow the system appearance (see config/theme.lua)
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = function()
                vim.cmd.colorscheme(require("config.theme").system_colorscheme())
            end,
        },
    },
    { "catppuccin/nvim",         name = "catppuccin", lazy = false, priority = 1000 },
    { "folke/tokyonight.nvim",   enabled = false },

    -- lvim never had noice (it was commented out), keep the classic cmdline and messages
    { "folke/noice.nvim",        enabled = false },

    {
        "folke/snacks.nvim",
        opts = {
            -- lvim had indent-blankline disabled
            indent = { enabled = false },
            picker = {
                sources = {
                    explorer = {
                        layout = { layout = { width = 30, min_width = 30 } },
                    },
                },
            },
        },
        keys = {
            -- Replaced by toggle comment and the Session group (see config/keymaps.lua)
            { "<leader>/", false },
            { "<leader>S", false },
        },
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        opts = function(_, opts)
            local icons = LazyVim.config.icons

            -- Paste mode indicator
            local function has_paste()
                if vim.o.paste then
                    return "PASTE MODE"
                end
                return ""
            end

            local sections = opts.sections
            sections.lualine_a = { has_paste, "mode" }
            sections.lualine_b = {
                {
                    "branch",
                    fmt = function(str)
                        -- Only show last characters of the branch if too long
                        return str:sub(-48)
                    end,
                },
                {
                    "diff",
                    symbols = {
                        added = icons.git.added,
                        modified = icons.git.modified,
                        removed = icons.git.removed,
                    },
                    source = function()
                        local gitsigns = vim.b.gitsigns_status_dict
                        if gitsigns then
                            return {
                                added = gitsigns.added,
                                modified = gitsigns.changed,
                                removed = gitsigns.removed,
                            }
                        end
                    end,
                },
            }
            sections.lualine_c = {
                {
                    "filename",
                    file_status = true,
                    newfile_status = true,
                    path = 2,
                    symbols = {
                        modified = "[*]",
                        readonly = "[READONLY]",
                    },
                },
            }

            -- The diff moved to section b; add diagnostics and filetype where lvim had them
            sections.lualine_x = vim.tbl_filter(function(component)
                return not (type(component) == "table" and component[1] == "diff")
            end, sections.lualine_x)
            table.insert(sections.lualine_x, 1, {
                "diagnostics",
                symbols = {
                    error = icons.diagnostics.Error,
                    warn = icons.diagnostics.Warn,
                    info = icons.diagnostics.Info,
                    hint = icons.diagnostics.Hint,
                },
            })
            table.insert(sections.lualine_x, "filetype")
        end,
    },

    -- No neck pain
    {
        "shortcuts/no-neck-pain.nvim",
        version = "*",
        dependencies = { "catppuccin" },
        config = function()
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
                    enableOnVimEnter = "safe",
                },
                buffers = nnp_buffers(),
            }

            require("no-neck-pain").setup(nnp_opts)

            -- Runs before the plugin's own (scheduled) reload, which reuses nnp_opts.
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    nnp_opts.buffers = nnp_buffers()
                    -- keep the live config current too, so enabling later uses the right color
                    if _G.NoNeckPain and _G.NoNeckPain.config then
                        _G.NoNeckPain.config = require("no-neck-pain.config").defaults(vim.deepcopy(nnp_opts))
                    end
                    -- Queued after the plugin's own scheduled reload. That reload only updates its
                    -- config; existing side windows keep their old highlights, so repaint them.
                    vim.schedule(function()
                        if _G.NoNeckPain == nil or _G.NoNeckPain.state == nil or not _G.NoNeckPain.state.enabled then
                            return
                        end
                        local state = require("no-neck-pain.state")
                        for _, side in ipairs({ "left", "right" }) do
                            require("no-neck-pain.colors").init(state:get_side_id(side), side)
                        end
                    end)
                end,
            })
        end,
    },
}
