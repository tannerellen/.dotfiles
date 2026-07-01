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
			"saghen/blink.cmp",
			-- "pmizio/typescript-tools.nvim", -- Alternative to typescript server (requires plenary)
		},
	}, -- easily configure language servers

	{
		"saghen/blink.cmp",
		dependencies = "rafamadriz/friendly-snippets",
		event = "InsertEnter",
		version = "v0.*",
		opts = {
			keymap = {
				preset = "default",
			},
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			cmdline = {
				enabled = false, -- Disable command line completion
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					lsp = {
						min_keyword_length = 2, -- Number of characters to trigger porvider
						score_offset = 0, -- Boost/penalize the score of the items
					},
					path = {
						min_keyword_length = 0,
					},
					snippets = {
						min_keyword_length = 2,
					},
					buffer = {
						min_keyword_length = 4,
						max_items = 5,
					},
				},
			},
			signature = { enabled = true },
		},
	},

	-- treesitter configuration
	{
		"romus204/tree-sitter-manager.nvim",
		-- tree-sitter CLI must be installed system-wide
		-- https://github.com/tree-sitter/tree-sitter/
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring", -- allow comments in mixed content files like jsx, html and svelte
			"windwp/nvim-ts-autotag", -- autoclose html tags
		},
		config = function()
			require("plugins.config.treesitter")
		end,
	},
	{
		"glepnir/lspsaga.nvim",
		event = "LspAttach",
		config = function()
			require("plugins.config.lsp.lspsaga")
		end,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
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
		"numToStr/Comment.nvim",
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

	-- clipboard access
	{
		"ojroques/nvim-osc52", -- allows copying text and setting system clipboard
		event = { "BufReadPre", "BufNewFile" },
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
		config = function()
			require("render-markdown").setup({
				completions = { lsp = { enabled = true } },
			})
		end,
	},
	{
		"lambdalisue/vim-suda",
		config = function()
			-- Add a :W command to use SudaWrite
			vim.api.nvim_create_user_command("W", "SudaWrite", {})
		end,
	}, -- save files as root
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" },
		},
		-- build = "make tiktoken",
		opts = {
			-- See Configuration section for options
			model = "gpt-4.1", -- AI model to use
			temperature = 0.1, -- Lower = focused, higher = creative
			trusted_tools = nil, -- Require approval for all tool calls
			window = {
				layout = "vertical", -- 'vertical', 'horizontal', 'float'
				width = 0.5, -- 50% of screen width
			},
			auto_insert_mode = true, -- Enter insert mode when opening
		},
	},
	{
		"isaksamsten/sia.nvim",

		opts = {
			settings = { model = "copilot/claude-sonnet-4.6" },
		},
		dependencies = {
			{
				"rickhowe/diffchar.vim",
				keys = {
					{ "[z", "<Plug>JumpDiffCharPrevStart", desc = "Previous diff", silent = true },
					{ "]z", "<Plug>JumpDiffCharNextStart", desc = "Next diff", silent = true },
					{ "do", "<Plug>GetDiffCharPair", desc = "Obtain diff", silent = true },
					{ "dp", "<Plug>PutDiffCharPair", desc = "Put diff", silent = true },
				},
			},
		},
	},
	{
		"kamegoro/tobira.nvim",
		event = "VeryLazy",
		opts = {},
	},
	-- codeium ai code completion
	-- {
	-- 	"Exafunction/codeium.nvim",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"hrsh7th/nvim-cmp",
	-- 	},
	-- 	event = "BufEnter",
	-- 	config = function()
	-- 		require("codeium").setup({})
	-- 	end,
	-- },
}
