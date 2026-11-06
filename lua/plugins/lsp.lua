return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- angularls itself is enabled by the lang.angular extra
                angularls = {
                    filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" },
                },
                groovyls = {
                    capabilities = {
                        general = { positionEncodings = { "utf-16" } },
                    },
                },
            },
        },
    },

    -- Formatting: lvim only registered prettier for these filetypes
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                typescript = { "prettier" },
                typescriptreact = { "prettier" },
                javascript = { "prettier" },
                javascriptreact = { "prettier" },
                json = { "prettier" },
                html = { "prettier" },
                css = { "prettier" },
            },
        },
    },
    {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "prettier", "groovy-language-server" } },
    },

    -- Tests (keys follow the lvim <leader>t group)
    { "nvim-neotest/neotest-jest" },
    {
        "nvim-neotest/neotest",
        dependencies = { "antoinemadec/FixCursorHold.nvim" },
        opts = {
            adapters = {
                ["neotest-jest"] = {
                    jestCommand = "npm test --",
                },
            },
        },
        keys = {
            { "<leader>tr", function() require("neotest").run.run() end,                                desc = "Run" },
            { "<leader>tR", function() require("neotest").run.run(vim.fn.expand("%")) end,             desc = "Run (file)" },
            { "<leader>ts", function() require("neotest").run.stop() end,                              desc = "Stop" },
            { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end,           desc = "Debug" },
            { "<leader>to", "<cmd>Neotest output-panel<cr>",                                           desc = "Output Window" },
            { "<leader>tO", "<cmd>Neotest summary<cr>",                                                desc = "Summary Window" },
            -- Moved to make room for the bindings above
            { "<leader>tS", false },
        },
    },
}
