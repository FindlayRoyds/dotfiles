vim.g.mapleader = " " -- Leader key for shortcuts
vim.g.localmapleader = " "
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus" -- Share yank register with system clipboard
vim.opt.mouse = "" -- Disable mouse
vim.opt.laststatus = 2 -- Hide status bar when not in split
vim.opt.ruler = false -- Hide cursor position readout bottom right
vim.opt.cmdheight = 0 -- Hide command bar when not in use
vim.opt.showmode = false -- Hide --INSERT-- readout
vim.opt.undofile = true -- Persistent undo history
vim.opt.scrolloff = 10 -- Vertical padding
vim.opt.sidescrolloff = 12 -- Horizontal padding
vim.opt.splitright = true -- Open vertical splits to the right
vim.opt.splitbelow = true -- Open horizontal splits below
vim.opt.signcolumn = "yes" -- Show diagnostics to left of line numbers, always have space
vim.opt.shortmess:append("I") -- Hide slpash screen stuff
vim.opt.wrap = false -- Stop lines wrapping
vim.opt.updatetime = 250 -- Decrease update time after stopping typing for linters, diagnostics, etc
vim.opt.timeoutlen = 500 -- Decrease mapped sequence wait time
vim.g.have_nerd_font = true
vim.o.inccommand = "split" -- Preview substitutions while typing

-- Don't continue comments onto newlines
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Ignore case when searching
vim.opt.ignorecase = true
vim.opt.smartcase = true -- Uses case when typing capital letter

-- Enable global autoread to update buffer to match file
vim.opt.autoread = true
-- Trigger checktime when focusing Neovim or entering a buffer
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    pattern = "*",
    callback = function()
        if vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
        end
    end,
})

-- Highlight line and line number of active window
local cursorline_group = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = cursorline_group,
    callback = function()
        vim.opt_local.cursorline = true
    end,
})
vim.api.nvim_create_autocmd({ "WinLeave" }, {
    group = cursorline_group,
    callback = function()
        vim.opt_local.cursorline = false
    end,
})

-- Display certain whitespace characters in the editor
vim.o.list = true
vim.opt.listchars = { trail = "·", nbsp = "␣" }

vim.diagnostic.config({
    severity_sort = true, -- Prioritise showing E>W>H diagnostics
    underline = { severity = { min = vim.diagnostic.severity.WARN } },
    jump = { float = true },
})

-- =====================================================================
-- KEYBINDS
-- =====================================================================

vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("n", "<leader>h", "<C-w>h")
vim.keymap.set("n", "<leader>j", "<C-w>j")
vim.keymap.set("n", "<leader>k", "<C-w>k")
vim.keymap.set("n", "<leader>l", "<C-w>l")

vim.keymap.set("n", "<leader>H", "<C-w>H")
vim.keymap.set("n", "<leader>J", "<C-w>J")
vim.keymap.set("n", "<leader>K", "<C-w>K")
vim.keymap.set("n", "<leader>L", "<C-w>L")

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-terminal-config", { clear = true }),
    callback = function()
        vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { buffer = 0, desc = "Exit terminal mode" })
        vim.keymap.set("t", "<Space>", "<Space>", { buffer = 0 }) -- Force Space to be sent immediately in Terminal mode
    end,
})

vim.keymap.set("n", "<leader>s", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format current buffer" })

vim.keymap.set("n", "grd", function()
    vim.diagnostic.open_float()
end)

-- =====================================================================
-- PACKAGES
-- =====================================================================

-- PackChanged is not a real event, not that it matters, nvim-treesitter is archived :(
-- vim.api.nvim_create_autocmd("PackChanged", {
--     callback = function(event)
--         -- Trigger TSUpdate automatically when nvim-treesitter updates or installs
--         if event.data.kind == "update" and event.data.spec.name == "nvim-treesitter" then
--             pcall(vim.cmd, "TSUpdate")
--         end
--     end,
-- })

vim.pack.add({
    -- Dependencies
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-lua/plenary.nvim",

    "https://github.com/williamboman/mason.nvim",
    "https://github.com/williamboman/mason-lspconfig.nvim",
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
    "https://github.com/NMAC427/guess-indent.nvim",
    "https://github.com/m4xshen/hardtime.nvim",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/catppuccin/nvim",
    "https://github.com/kylechui/nvim-surround",
    "https://github.com/akinsho/toggleterm.nvim",
    "https://github.com/okuuva/auto-save.nvim",
    "https://github.com/windwp/nvim-autopairs",
    "https://github.com/folke/snacks.nvim",
    {
        src = "https://github.com/mrcjkb/rustaceanvim",
        version = vim.version.range("^9"),
    },
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/rmagatti/auto-session",
})

require("catppuccin").setup({
    flavour = "mocha",
})

vim.cmd.colorscheme("catppuccin")

require("blink.cmp").setup({
    keymap = { preset = "super-tab" },
    completion = { list = { max_items = 4 } },
    sources = {
        default = { "lsp" },
    },
})

require("guess-indent").setup({})

require("hardtime").setup({
    max_count = 6,
})

require("gitsigns").setup()
vim.keymap.set("n", "<leader>gp", function()
    require("gitsigns").preview_hunk_inline()
end)
vim.keymap.set("n", "<leader>gr", function()
    require("gitsigns").reset_hunk()
end)
vim.keymap.set("n", "<leader>gn", function()
    require("gitsigns").next_hunk()
end)
vim.keymap.set("n", "<leader>gN", function()
    require("gitsigns").prev_hunk()
end)

require("nvim-surround").setup({})

require("toggleterm").setup({
    open_mapping = nil,
    direction = "float",
    start_in_insert = true,
    persist_size = true,
    on_open = function(term)
        vim.schedule(function()
            vim.cmd("startinsert!")
        end)
    end,
})

require("snacks").setup({
    picker = { formatters = { file = { filename_first = true } } },
    notifier = { timeout = 5000 },
    scroll = {},
})
vim.keymap.set("n", "<leader>f", function()
    Snacks.picker.smart({ filter = { cwd = true } })
end)
vim.keymap.set("n", "<leader>p", function()
    Snacks.picker()
end)
vim.keymap.set("n", "<leader>o", function()
    Snacks.picker.zoxide()
end)
vim.keymap.set("n", "gd", function()
    Snacks.picker.lsp_definitions()
end)
vim.keymap.set("n", "grr", function()
    Snacks.picker.lsp_references()
end)

require("auto-save").setup({
    enabled = true,
    condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")
        local buf_name = vim.api.nvim_buf_get_name(buf)

        if buf_name ~= "" and fn.filereadable(buf_name) == 0 then
            Snacks.notify.warn("File missing: auto-save aborted", { title = "Auto-save" })
            return false
        end

        if
            fn.getbufvar(buf, "&modifiable") == 1
            and utils.not_in(fn.getbufvar(buf, "&filetype"), { "gitcommit", "gitrebase" })
        then
            return true
        end
        return false
    end,
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "ruff", "ty", "stylua", "taplo" },
})
vim.lsp.config("ty", { autostart = true, capabilities = { offsetEncoding = { "utf-16" } } })
vim.lsp.enable("ty")
vim.lsp.config("ruff", { autostart = true })
vim.lsp.enable("ruff")
vim.lsp.config("stylua", { autostart = true })
vim.lsp.enable("stylua")
vim.lsp.config("taplo", { autostart = true })
vim.lsp.enable("taplo")

require("nvim-treesitter").setup({
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
})

require("nvim-autopairs").setup()

require("auto-session").setup({
    suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
    cwd_change_handling = true,
})
