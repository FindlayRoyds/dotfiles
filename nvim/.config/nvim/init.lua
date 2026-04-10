-- GENERAL SETTINGS
vim.g.mapleader = " " -- Leader key for shortcuts
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus" -- Share yank register with system clipboard
vim.opt.mouse = "" -- Disable mouse
vim.opt.laststatus = 1 -- Hide status bar when not in split
vim.opt.ruler = false -- Hide cursor position readout bottom right
vim.opt.cmdheight = 0 -- Hide command bar when not in use
vim.opt.showmode = false -- Hide --INSERT-- readout
vim.opt.undofile = true -- Persistent undo history
vim.opt.scrolloff = 10 -- Vertical padding
vim.opt.sidescrolloff = 12 -- Horizontal padding
vim.opt.splitright = true -- Open vertical splits to the right
vim.opt.splitbelow = true -- Open horizontal splits below
vim.opt.signcolumn = "yes" -- Show diagnostics to left of line numbers, always have space
vim.diagnostic.config({
	severity_sort = true, -- Prioritise showing E>W>H diagnostics
})
vim.opt.cursorline = true -- Highlight current line number
vim.opt.cursorlineopt = "number" -- Don't highlight entire line only number
vim.opt.shortmess:append("I") -- Hide slpash screen stuff
vim.opt.wrap = false -- Stop lines wrapping

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

-- KEYBINDS
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

vim.keymap.set("n", "gd", function()
	Snacks.picker.lsp_definitions()
end, { desc = "LSP Definition (Snacks)" })

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

-- LAZY.NVIM PLUGINS
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"saghen/blink.cmp",
		version = "1.*",
		opts = {
			keymap = { preset = "super-tab" },
			completion = {
				list = { max_items = 4 },
			},
		},
	},
	{ "NMAC427/guess-indent.nvim", opts = {} },
	{
		"m4xshen/hardtime.nvim",
		lazy = false,
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
	},
	{
		"erl-koenig/theme-hub.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("theme-hub").setup({
				auto_install_on_select = true,
			})
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			flavour = "mocha", -- options: latte, frappe, macchiato, mocha
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				open_mapping = nil,
				direction = "float",
				start_in_insert = true,
				persist_size = true,
				on_open = function(term) -- Put terminal in insert every time it's opened
					vim.schedule(function()
						vim.cmd("startinsert!")
					end)
				end,
			})
		end,
	},
	{
		"okuuva/auto-save.nvim",
		opts = {
			enabled = true,
			debounce_delay = 200,
			condition = function(buf)
				local fn = vim.fn
				local utils = require("auto-save.utils.data")

				-- Don't save for gitcommit, gitrebase, or non-modifiable files
				if
					fn.getbufvar(buf, "&modifiable") == 1
					and utils.not_in(fn.getbufvar(buf, "&filetype"), { "gitcommit", "gitrebase" })
				then
					return true
				end
				return false
			end,
		},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	{
		"folke/snacks.nvim",
		opts = {
			picker = {
				formatters = {
					file = {
						filename_first = true,
					},
				},
			},
			scroll = { },
		},
		keys = {
			{
				"<leader>f",
				function()
					Snacks.picker.smart({ filter = { cwd = true } })
				end,
				desc = "Smart find (files + recent)",
			},
			{
				"<leader>p",
				function()
					Snacks.picker()
				end,
				desc = "All pickers",
			},
			{
				"<leader>o",
				function()
					Snacks.picker.zoxide()
				end,
				desc = "Zoxide picker, change working directory",
			},
		},
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^8",
		lazy = false,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = { "ruff", "ty", "stylua" },
			})

			vim.lsp.enable("ty")
			vim.lsp.enable("ruff")
			vim.lsp.enable("stylua")

			vim.lsp.config("ty", {
				autostart = true,
				capabilities = { offsetEncoding = { "utf-16" } },
			})
			vim.lsp.config("ruff", {
				autostart = true,
			})
			vim.lsp.config("stylua", {
				autostart = true,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			auto_install = true,

			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},

			indent = { enable = true },
		},
	},
}, {
	install = { colorscheme = { theme } },
})
