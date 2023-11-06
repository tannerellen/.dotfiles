return {

	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000, -- Load before any other start plugins
	}, -- preferred colorscheme

	{
		"kylechui/nvim-surround",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("nvim-surround").setup()
		end,
	}, -- add, delete, change surroundings (it's awesome)

	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("plugins.config.lualine")
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- fuzzy finding w/ telescope
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		config = function()
			require("plugins.config.telescope")
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, -- make telescope fuzzy finding faster and better sorting with fzf native
			"nvim-tree/nvim-web-devicons",
		},
	}, -- fuzzy finder

	{
		"stevearc/oil.nvim",
		config = function()
			require("plugins.config.oil")
		end,
		-- Optional dependencies
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- managing & installing lsp servers, linters & formatters
	{
		"williamboman/mason.nvim",
		config = function()
			require("plugins.config.lsp.mason")
		end,
		dependencies = {
			"williamboman/mason-lspconfig.nvim", -- bridges gap between mason & lspconfig
			"WhoIsSethDaniel/mason-tool-installer.nvim", -- sets up automatic installs for mason
		},
	}, -- in charge of managing lsp servers, linters & formatters

	-- configuring lsp servers
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("plugins.config.lsp.lspconfig")
		end,
		dependencies = {
			"pmizio/typescript-tools.nvim", -- Alternative to typescript server (requires plenary)
		},
	}, -- easily configure language servers

	{
		"zeioth/garbage-day.nvim",
		event = "BufEnter",
		opts = {
			-- your options here
		},
	}, -- Kills unused lsp clients
	-- autocompletion and snippets
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		config = function()
			require("plugins.config.nvim-cmp")
		end,
		dependencies = {
			"L3MON4D3/LuaSnip", -- snippet engine
			"saadparwaiz1/cmp_luasnip", -- for autocompletion
			"rafamadriz/friendly-snippets", -- useful snippets
			"hrsh7th/cmp-buffer", -- source for text in buffer
			"hrsh7th/cmp-path", -- source for file system paths
			"hrsh7th/cmp-nvim-lsp", -- for autocompletion
			"hrsh7th/cmp-nvim-lsp-signature-help", -- function parameter hints
			"onsails/lspkind.nvim", -- vs-code like icons for autocompletion
		},
	}, -- completion plugin

	-- treesitter configuration
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
		config = function()
			require("plugins.config.treesitter")
		end,
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring", -- allow comments in mixed content files like jsx, html and svelte
			"windwp/nvim-ts-autotag", -- autoclose html tags
		},
	},

	{
		"glepnir/lspsaga.nvim",
		event = "LspAttach",
		config = function()
			require("plugins.config.lsp.lspsaga")
		end,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-treesitter/nvim-treesitter",
			-- please make sure you install markdown and markdown_inline treesitter language parsers
		},
	}, -- enhanced lsp uis

	-- formatting & linting
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("plugins.config.conform")
		end,
	},

	-- commenting
	{
		"terrortylor/nvim-comment",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("plugins.config.comment")
		end,
	}, -- commenting plugin

	-- auto closing
	{
		"windwp/nvim-autopairs",
		event = { "InsertEnter" },
		config = function()
			require("plugins.config.autopairs")
		end,
	}, -- autoclose parens, brackets, quotes, etc...

	-- git integration
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("plugins.config.gitsigns")
		end,
	}, -- show line modifications on left hand side

	{
		"sindrets/diffview.nvim",
		config = function()
			require("plugins.config.diffview")
		end,
		dependencies = { "nvim-lua/plenary.nvim" },
	}, -- diffview (diffing and merging git commits)

	-- harpoon (file marks)
	{
		"ThePrimeagen/harpoon",
		config = function()
			require("harpoon").setup()
		end,
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- clipboard access
	{
		"ojroques/nvim-osc52", -- allows copying text and setting system clipboard
		event = { "BufReadPre", "BufNewFile" },
	},

	-- github copilot
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({})
		end,
	},
}
