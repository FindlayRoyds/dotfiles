vim.g.mapleader = " " -- Leader key for shortcuts
vim.g.localmapleader = " "
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus" -- Share yank register with system clipboard
vim.opt.mouse = "" -- Disable mouse
vim.opt.cmdheight = 0 -- Hide command bar when not in use
vim.opt.undofile = true -- Persistent undo history
vim.opt.scrolloff = 10 -- Vertical padding
vim.opt.sidescrolloff = 24 -- Horizontal padding
vim.opt.splitright = true -- Open vertical splits to the right
vim.opt.splitbelow = true -- Open horizontal splits below
vim.opt.signcolumn = "yes" -- Show diagnostics to left of line numbers, always have space
vim.opt.shortmess:append("I") -- Hide slpash screen stuff
vim.opt.wrap = false -- Stop lines wrapping
vim.opt.updatetime = 250 -- Decrease update time after stopping typing for linters, diagnostics, etc
vim.g.have_nerd_font = true
vim.opt.inccommand = "split" -- Preview substitutions while typing
vim.opt.swapfile = false -- Don't need swap files for recovery, use git etc
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,t:ver25" -- Line cursor in terminal mode
vim.opt.undolevels = 2000 -- Longer undo history
vim.opt.number = true -- Hybrid line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.ignorecase = true -- Ignore case when searching
vim.opt.smartcase = true -- Uses case when typing capital letter
vim.opt.autoread = true -- Enable global autoread to update buffer to match file

vim.diagnostic.config({
    severity_sort = true, -- Prioritise showing E>W>H diagnostics
    underline = { severity = { min = vim.diagnostic.severity.WARN } },
    jump = { float = true },
})

-- Ensure homebrew bin is on PATH (needed for tools like tree-sitter)
for _, brew_bin in ipairs({ "/opt/homebrew/bin", "/usr/local/bin", "/home/linuxbrew/.linuxbrew/bin" }) do
    if vim.fn.isdirectory(brew_bin) == 1 and not vim.env.PATH:find(brew_bin, 1, true) then
        vim.env.PATH = brew_bin .. ":" .. vim.env.PATH
    end
end

-- =====================================================================
-- KEYBINDS
-- =====================================================================

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Window navigation
vim.keymap.set("n", "<leader>h", "<C-w>h")
vim.keymap.set("n", "<leader>j", "<C-w>j")
vim.keymap.set("n", "<leader>k", "<C-w>k")
vim.keymap.set("n", "<leader>l", "<C-w>l")
vim.keymap.set("n", "<leader>H", "<C-w>H")
vim.keymap.set("n", "<leader>J", "<C-w>J")
vim.keymap.set("n", "<leader>K", "<C-w>K")
vim.keymap.set("n", "<leader>L", "<C-w>L")

-- Gitsigns
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

-- Snacks pickers
vim.keymap.set("n", "<leader>p", "<Nop>") -- Prevent 'p' from pasting after timeout
vim.keymap.set("n", "<leader>pf", function()
    Snacks.picker.smart({ filter = { cwd = true } })
end)
vim.keymap.set("n", "<leader>pp", function()
    Snacks.picker()
end)
vim.keymap.set("n", "<leader>po", function()
    Snacks.picker.zoxide()
end)
vim.keymap.set("n", "<leader>pg", function()
    Snacks.picker.grep()
end)
vim.keymap.set("n", "<leader>pe", function()
    Snacks.picker.explorer({ ignored = true, hidden = true })
end)
vim.keymap.set("n", "<leader>pu", function()
    Snacks.picker.undo()
end)
vim.keymap.set("n", "<leader>pd", function()
    Snacks.picker.diagnostics()
end)
vim.keymap.set("n", "gd", function()
    Snacks.picker.lsp_definitions()
end)
vim.keymap.set("n", "grr", function()
    Snacks.picker.lsp_references()
end)
vim.keymap.set("n", "giw", function()
    local word = vim.fn.expand("<cword>")
    local ok = pcall(function()
        Snacks.picker.grep({
            search = word,
        })
    end)
    if not ok then
        Snacks.notify("Failed to grep word")
    end
end)

-- LSP related
vim.keymap.set("n", "<leader>s", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format current buffer" })
vim.keymap.set("n", "grd", function()
    vim.diagnostic.open_float()
end)

-- Leap
vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
vim.keymap.set('n',               'S', '<Plug>(leap-from-window)')

-- Terminal
vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
-- Vibe coded function to immediately send esc in terminal (e.g., for when in vim inside nvim terminal)
vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-terminal-config", { clear = true }),
    callback = function(args)
        local buf = args.buf

        vim.keymap.set("t", "<Esc>", function()
            -- vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { buffer = 0, desc = "Exit terminal mode" })
            local term_id = vim.b[buf].terminal_job_id

            if vim.b[buf].esc_timer then
                -- Second <Esc> pressed within the timeout window
                vim.b[buf].esc_timer = false
                local termcodes = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
                vim.api.nvim_feedkeys(termcodes, "n", false)
            else
                -- First <Esc> pressed: start timer and send raw Esc immediately
                vim.b[buf].esc_timer = true

                if term_id then
                    vim.api.nvim_chan_send(term_id, "\27") -- Send raw Escape byte
                end

                vim.defer_fn(function()
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.b[buf].esc_timer = false
                    end
                end, vim.o.timeoutlen) -- Uses your standard Neovim timeoutlen
            end
        end, { buffer = buf, desc = "Immediate Esc or double Esc to exit" })
    end,
})

-- =====================================================================
-- PACKAGES
-- =====================================================================

vim.pack.add({
    -- LSP / AST
    "https://github.com/romus204/tree-sitter-manager.nvim",
    "https://github.com/williamboman/mason.nvim",
    "https://github.com/williamboman/mason-lspconfig.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    { src = "https://github.com/mrcjkb/rustaceanvim", version = vim.version.range("^9") },

    -- Git integration
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/akinsho/git-conflict.nvim",

    -- Large plugins / visual changes
    "https://github.com/folke/snacks.nvim",
    "https://github.com/nvim-lualine/lualine.nvim",
    "https://github.com/akinsho/toggleterm.nvim",
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },

    -- Small QOL behavior changes
    "https://github.com/kylechui/nvim-surround",
    "https://github.com/gbprod/cutlass.nvim",
    "https://github.com/NMAC427/guess-indent.nvim",
    "https://github.com/windwp/nvim-autopairs",
    "https://github.com/okuuva/auto-save.nvim",
    "https://github.com/rmagatti/auto-session",
    "https://codeberg.org/andyg/leap.nvim",

    -- Themes
    "https://github.com/catppuccin/nvim",
    "https://github.com/ellisonleao/gruvbox.nvim",
    "https://github.com/folke/tokyonight.nvim",
})

-- Before importing local config so it can be overridden
require("gruvbox").setup({
    palette_overrides = {
        bright_green = "#96ab3f",
        -- bright_aqua = "#fabd2f",
        bright_aqua = "#83a598",
    },
    overrides = {
        SignColumn = { bg = "none" },
        CursorLineSign = { bg = "none" },
        CursorLineNr = { bg = "none" },
    },
})
vim.cmd.colorscheme("gruvbox")

require("auto-session").setup({
    suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
    cwd_change_handling = {
        restore_upcoming_session = true,
        pre_cwd_changed_hook = function()
            -- Clear buffers when changing to a dir that doesn't have a session saved
            vim.cmd("silent! %bd!")
        end,
    },
})

require("lualine").setup({
    options = { section_separators = "", component_separators = "" },
    sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "diff", "diagnostics" },
        lualine_y = {},
        lualine_z = {},
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },
})

require("gitsigns").setup()

require("snacks").setup({
    picker = {
        formatters = { file = { filename_first = true } },
        sources = {
            zoxide = {
                transform = function(item)
                    if item.file == vim.uv.cwd() then
                        return false
                    end
                    return item
                end,
                layout = {
                    preview = false,
                    preset = "select",
                    layout = {
                        backdrop = 60,
                        height = 0.75,
                        width = 0.4,
                    },
                },
                format = function(item)
                    local path = item.file or item.text
                    local dir_name = vim.fn.fnamemodify(path, ":t")
                    -- Get the parent directory and shorten home to '~'
                    local parent_path = vim.fn.fnamemodify(path, ":~:h")

                    -- Handle edge case for root directory
                    if dir_name == "" then
                        dir_name = parent_path
                        parent_path = ""
                    end

                    return {
                        { "󰉋 ", "Directory" }, -- Folder icon
                        { dir_name, "Directory" }, -- Highlighted directory name
                        { "  " }, -- Spacing
                        { parent_path, "SnacksPickerDir" }, -- Parent path only (without the dir itself)
                    }
                end,
                -- Override the default confirm action so it doesn't open the file picker
                confirm = function(picker, item)
                    picker:close()
                    if item and item.file then
                        vim.api.nvim_set_current_dir(item.file)
                        vim.fn.jobstart({ "zoxide", "add", item.file })
                    end
                end,
            },
        },
    },
    notifier = { timeout = 5000 },
    scroll = {},
    input = {
        win = {
            -- Open input in normal mode
            on_win = function()
                vim.schedule(function()
                    vim.cmd.stopinsert()
                    vim.api.nvim_win_set_cursor(0, { 1, 0 })
                end)
            end,
        },
    },
})

require("tree-sitter-manager").setup({
    auto_install = true,
    highlight = true,
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "ruff", "ty", "stylua", "taplo", "clangd", "lua_ls" },
})
vim.lsp.config("ty", { autostart = true })
vim.lsp.enable("ty")
vim.lsp.config("ruff", { autostart = true })
vim.lsp.enable("ruff")
vim.lsp.config("stylua", { autostart = true })
vim.lsp.enable("stylua")
vim.lsp.config("taplo", { autostart = true })
vim.lsp.enable("taplo")
vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders=0",
        "--fallback-style=llvm",
    },
    autostart = true,
})
vim.lsp.enable("clangd")
vim.lsp.config("lua_ls", {
    autostart = true,
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                globals = { "vim", "Snacks" },
            },
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    "${3rd}/luv/library", -- Enables vim.uv / libuv completions
                },
                checkThirdParty = false,
            },
        },
    },
})
vim.lsp.enable("lua_ls")

require("blink.cmp").setup({
    keymap = { preset = "super-tab" },
    completion = { list = { max_items = 4 } },
    sources = {
        default = { "lsp" },
    },
})

require("guess-indent").setup({})

require("nvim-surround").setup({})

local toggleterm_backdrop = nil
require("toggleterm").setup({
    open_mapping = nil,
    direction = "float",
    start_in_insert = true,
    persist_size = true,
    float_opts = {
        border = "rounded",
    },
    on_open = function(_)
        vim.api.nvim_set_hl(0, "ToggleTermBackdrop", { bg = "#000000" })
        local buf = vim.api.nvim_create_buf(false, true)
        toggleterm_backdrop = vim.api.nvim_open_win(buf, false, {
            relative = "editor",
            row = 0,
            col = 0,
            width = vim.o.columns,
            height = vim.o.lines,
            style = "minimal",
            border = "none",
            focusable = false,
            zindex = 49,
        })
        vim.wo[toggleterm_backdrop].winhighlight = "Normal:ToggleTermBackdrop"
        vim.wo[toggleterm_backdrop].winblend = 60
        vim.schedule(function()
            vim.cmd("startinsert!")
        end)
    end,
    on_close = function(_)
        if toggleterm_backdrop and vim.api.nvim_win_is_valid(toggleterm_backdrop) then
            vim.api.nvim_win_close(toggleterm_backdrop, true)
            toggleterm_backdrop = nil
        end
    end,
})

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

require("nvim-autopairs").setup()

require("cutlass").setup({
    cut_key = "m",
})

require("git-conflict").setup({})

-- =====================================================================
-- AUTOCOMMANDS
-- =====================================================================

local bad_height = 45
local poll_interval = 10000
local timer = vim.uv.new_timer()
if timer ~= nil then
    timer:start(0, poll_interval, function()
        vim.schedule(function()
            if vim.o.lines == bad_height then
                Snacks.notify.warn("Press f11 to go fullscreen")
            end
        end)
    end)
end

-- Don't continue comments onto newlines
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

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

-- Enter insert mode when switching to / opening a terminal
vim.api.nvim_create_autocmd({ "WinEnter", "TermOpen" }, {
    group = vim.api.nvim_create_augroup("TerminalAutoInsert", { clear = true }),
    callback = function()
        if vim.bo.buftype == "terminal" then
            vim.cmd("startinsert!")
        end
    end,
})

-- Highlight text being yanked
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Close toggle term sessions when changing working dir
vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
        local ok, toggleterm = pcall(require, "toggleterm.terminal")
        if ok then
            local terminals = toggleterm.get_all()
            for _, term in ipairs(terminals) do
                term:shutdown()
            end
        end
    end,
})

-- Open zoxide picker when opening nvim in ~
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- Ensure no files were passed as arguments and CWD is home
        if vim.fn.argc() == 0 and vim.fn.getcwd() == vim.fn.expand("~") then
            -- vim.schedule prevents UI conflicts by waiting for Neovim to initialize
            vim.schedule(function()
                Snacks.picker.zoxide()
            end)
        end
    end,
})

-- Auto-save files (e.g. rename variable in file not open in buffer)
local default_apply_edit_handler = vim.lsp.handlers["textDocument/rename"]
vim.lsp.handlers["textDocument/rename"] = function(err, workspace_edit, ctx, config)
    local res = default_apply_edit_handler(err, workspace_edit, ctx, config)
    vim.cmd("silent! wa")

    return res
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = vim.api.nvim_create_augroup("AsymmetricScroll", { clear = true }),
    callback = function()
        local win_id = vim.api.nvim_get_current_win()
        if vim.wo[win_id].wrap then
            return
        end

        local win_info = vim.fn.getwininfo(win_id)[1]
        local effective_width = win_info.width - win_info.textoff
        local cursor_col = vim.fn.virtcol(".")
        local view = vim.fn.winsaveview()

        -- When to scroll to the left (half width of window)
        local left_scroll_trigger = math.floor(effective_width / 2)

        local target_leftcol = math.max(0, cursor_col - (effective_width - left_scroll_trigger))

        if view.leftcol > target_leftcol then
            view.leftcol = target_leftcol
            vim.fn.winrestview(view)
        end
    end,
})

pcall(require, "local") -- Local config
