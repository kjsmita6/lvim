-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Delete trailing space on save
local function clean_extra_space()
    local save_cursor = vim.fn.getpos(".")
    local old_query = vim.fn.getreg('/')
    vim.cmd([[silent! %s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
    vim.fn.setreg('/', old_query)
end

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("user_clean_extra_space", { clear = true }),
    pattern = { "*.txt", "*.js", "*.py", "*.wiki", "*.sh", "*.coffee", "*.ts" },
    callback = clean_extra_space,
})

-- Re-check the system appearance when nvim regains focus so a system switch is
-- picked up without a restart
vim.api.nvim_create_autocmd("FocusGained", {
    group = vim.api.nvim_create_augroup("user_system_colorscheme", { clear = true }),
    callback = function()
        local scheme = require("config.theme").system_colorscheme()
        if scheme ~= vim.g.colors_name then
            vim.cmd.colorscheme(scheme)
        end
    end,
})

-- CsvView
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("CsvViewAutoEnable", { clear = true }),
    pattern = { "csv", "tsv" },
    callback = function()
        require("csvview").enable()
    end,
})

vim.api.nvim_create_user_command("W", function()
    vim.cmd("silent w !sudo tee % > /dev/null")
    vim.cmd("edit!")
end, { desc = "Write the file with sudo" })
