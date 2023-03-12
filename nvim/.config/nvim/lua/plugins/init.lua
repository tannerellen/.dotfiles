return {

	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000, -- Load before any other start plugins
	}, -- preferred colorscheme

	"nvim-lua/plenary.nvim", -- lua functions that many plugins use

	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup({})
		end,
	}, -- add, delete, change surroundings (it's awesome)

	"inkarkat/vim-ReplaceWithRegister", -- replace with register contents using motion (gr + motion)

	-- commenting
	"JoosepAlviste/nvim-ts-context-commentstring", -- Allows different comment styles in same file (for example Svelte)

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
		dependencies = { "nvim-lua/plenary.nvim" },
	}, -- fuzzy finder

	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
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

	-- managing & installing lsp servers, linters & formatters
	{
		"williamboman/mason.nvim",
		config = function()
			require("plugins.config.lsp.mason")
		end,
	}, -- in charge of managing lsp servers, linters & formatters

	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("plugins.config.lsp.mason_lspconfig")
		end,
	}, -- bridges gap between mason & lspconfig

	-- configuring lsp servers
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("plugins.config.lsp.lspconfig")
		end,
	}, -- easily configure language servers

	"jose-elias-alvarez/typescript.nvim", -- additional functionality for typescript server (e.g. rename file & update imports)

	-- snippets
	{
		"L3MON4D3/LuaSnip", -- snippet engine

		dependencies = {
			"rafamadriz/friendly-snippets", -- useful snippets
		},
	},
	-- autocompletion
	{
		"hrsh7th/nvim-cmp",
		config = function()
			require("plugins.config.nvim-cmp")
		end,
		dependencies = {
			"saadparwaiz1/cmp_luasnip", -- for autocompletion
			"hrsh7th/cmp-buffer", -- source for text in buffer
			"hrsh7th/cmp-path", -- source for file system paths
			"hrsh7th/cmp-nvim-lsp", -- for autocompletion
			"hrsh7th/cmp-nvim-lsp-signature-help", -- function parameter hints
		},
	}, -- completion plugin

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

	{
		"glepnir/lspsaga.nvim",
		event = "BufRead",
		config = function()
			require("plugins.config.lsp.lspsaga")
		end,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			--Please make sure you install markdown and markdown_inline parser
			"nvim-treesitter/nvim-treesitter",
		},
	}, -- enhanced lsp uis

	"onsails/lspkind.nvim", -- vs-code like icons for autocompletion

	-- formatting & linting
	{
		"jose-elias-alvarez/null-ls.nvim",
		-- after = "nvim-lspconfig",
		config = function()
			require("plugins.config.lsp.null-ls")
		end,
	}, -- configure formatters & linters

	{
		"jayp0521/mason-null-ls.nvim",
	}, -- bridges gap b/w mason & null-ls

	-- auto closing
	{
		"windwp/nvim-autopairs",
		config = function()
			require("plugins.config.autopairs")
		end,
	}, -- autoclose parens, brackets, quotes, etc...

	{
		"windwp/nvim-ts-autotag",
	}, -- autoclose tags

	-- git integration
	{
		"lewis6991/gitsigns.nvim",
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
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	--
	-- "MunifTanjim/nui.nvim", -- for ui components used by other plugins (Don't think I need this)
	-- {
	-- 	"jcdickinson/codeium.nvim",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"MunifTanjim/nui.nvim",
	-- 		"hrsh7th/nvim-cmp",
	-- 	},
	-- 	config = function()
	-- 		require("codeium").setup({})
	-- 	end,
	-- },
}
