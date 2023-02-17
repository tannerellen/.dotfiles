return {
	"nvim-lua/plenary.nvim", -- lua functions that many plugins use

	{
		"sainnhe/gruvbox-material",
		priority = 1000, -- Load before any other start plugins
	}, -- preferred colorscheme

	"tpope/vim-surround", -- add, delete, change surroundings (it's awesome)
	"inkarkat/vim-ReplaceWithRegister", -- replace with register contents using motion (gr + motion)

	-- commenting
	{ "JoosepAlviste/nvim-ts-context-commentstring" }, -- Allows different comment styles in same file (for example Svelte)

	{
		"terrortylor/nvim-comment",
		config = function()
			require("plugins.config.comment")
		end,
	},

	-- vs-code like icons
	"nvim-tree/nvim-web-devicons",

	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		-- requires = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("plugins.config.lualine")
		end,
	},

	-- fuzzy finding w/ telescope
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-telescope/telescope-fzf-native.nvim", "nvim-telescope/telescope-file-browser.nvim" },
		-- requires = { "nvim-lua/plenary.nvim" },
		config = function()
			require("plugins.config.telescope")
		end,
	}, -- fuzzy finder

	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		-- requires = { "nvim-telescope/telescope.nvim" },
		-- after = "telescope.nvim",
		config = function()
			require("telescope").load_extension("fzf")
		end,
	}, -- make telescope fuzzy finding faster and better sorting with fzf native
	{
		"nvim-telescope/telescope-file-browser.nvim",
		config = function()
			require("telescope").load_extension("file_browser")
		end,
	}, -- use telescope to browse files and modify folder contents

	-- autocompletion
	{
		"hrsh7th/nvim-cmp",
		config = function()
			require("plugins.config.nvim-cmp")
		end,
	}, -- completion plugin
	"hrsh7th/cmp-buffer", -- source for text in buffer
	"hrsh7th/cmp-path", -- source for file system paths

	-- snippets
	"L3MON4D3/LuaSnip", -- snippet engine
	"saadparwaiz1/cmp_luasnip", -- for autocompletion
	"rafamadriz/friendly-snippets", -- useful snippets

	-- managing & installing lsp servers, linters & formatters
	{
		"williamboman/mason.nvim",
		dependencies = "williamboman/mason-lspconfig.nvim",
		config = function()
			require("plugins.config.lsp.mason")
		end,
	}, -- in charge of managing lsp servers, linters & formatters

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = "neovim/nvim-lspconfig",
		config = function()
			require("plugins.config.lsp.mason_lspconfig")
		end,
	}, -- bridges gap between mason & lspconfig

	-- configuring lsp servers
	{
		"neovim/nvim-lspconfig",
		dependencies = "jose-elias-alvarez/null-ls.nvim",
		-- after = "mason-lspconfig.nvim",
		config = function()
			require("plugins.config.lsp.lspconfig")
		end,
	}, -- easily configure language servers

	"jose-elias-alvarez/typescript.nvim", -- additional functionality for typescript server (e.g. rename file & update imports)

	"hrsh7th/cmp-nvim-lsp", -- for autocompletion

	{
		"glepnir/lspsaga.nvim",
		branch = "main",
		config = function()
			require("plugins.config.lsp.lspsaga")
		end,
	}, -- enhanced lsp uis

	"onsails/lspkind.nvim", -- vs-code like icons for autocompletion

	-- formatting & linting
	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = "jayp0521/mason-null-ls.nvim",
		-- after = "nvim-lspconfig",
		config = function()
			require("plugins.config.lsp.null-ls")
		end,
	}, -- configure formatters & linters

	{
		"jayp0521/mason-null-ls.nvim",
		-- after = "null-ls.nvim",
	}, -- bridges gap b/w mason & null-ls

	-- treesitter configuration
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
		config = function()
			require("plugins.config.treesitter")
		end,
	},

	-- auto closing
	{
		"windwp/nvim-autopairs",
		config = function()
			require("plugins.config.autopairs")
		end,
	}, -- autoclose parens, brackets, quotes, etc...

	{
		"windwp/nvim-ts-autotag",
		-- after = "nvim-treesitter"
	}, -- autoclose tags

	-- git integration
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("plugins.config.gitsigns")
		end,
	}, -- show line modifications on left hand side

	-- clipboard access
	"ojroques/nvim-osc52", -- allows copying text and setting system clipboard

	-- harpoon (file marks)
	{
		"ThePrimeagen/harpoon",
		config = function()
			require("harpoon").setup({
				-- config goes here
			})
		end,
	},

	-- A.I. completion / chatgpt
	-- use("aduros/ai.vim")

	--
	"MunifTanjim/nui.nvim", -- for ui components used by other plugins

	{
		"jackMort/ChatGPT.nvim",
		config = function()
			require("plugins.config.chat-gpt")
		end,
	},
}
