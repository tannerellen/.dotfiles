-- auto install packer if not installed
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end
local packer_bootstrap = ensure_packer() -- true if packer was just installed

-- import packer safely
local status, packer = pcall(require, "packer")
if not status then
	return
end

-- add list of plugins to install
return packer.startup(function(use)
	-- packer can manage itself
	use("wbthomason/packer.nvim")

	use({
		"lewis6991/impatient.nvim",
		config = function()
			-- call the plugin code immediately so it works on the rest of the plugins
			require("impatient") -- plugin command not config file
		end,
	}) -- decreases startup time with caching

	use("nvim-lua/plenary.nvim") -- lua functions that many plugins use

	use("sainnhe/gruvbox-material") -- preferred colorscheme

	-- essential plugins
	use("tpope/vim-surround") -- add, delete, change surroundings (it's awesome)
	use("inkarkat/vim-ReplaceWithRegister") -- replace with register contents using motion (gr + motion)

	-- commenting
	use({
		"terrortylor/nvim-comment",
		config = function()
			require("plugins.config.comment")
		end,
	})

	-- vs-code like icons
	use("nvim-tree/nvim-web-devicons")

	-- statusline
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("plugins.config.lualine")
		end,
	})

	-- fuzzy finding w/ telescope
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- dependency for better sorting performance
	use({
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		requires = { "nvim-lua/plenary.nvim" },
		after = "telescope-fzf-native.nvim",
		config = function()
			require("plugins.config.telescope")
		end,
	}) -- fuzzy finder

	use({
		"nvim-telescope/telescope-file-browser.nvim",
		requires = { "nvim-telescope/telescope.nvim" },
		after = "telescope.nvim",
		config = function()
			require("telescope").load_extension("file_browser")
		end,
	})

	-- autocompletion
	use({
		"hrsh7th/nvim-cmp",
		config = function()
			require("plugins.config.nvim-cmp")
		end,
	}) -- completion plugin
	use("hrsh7th/cmp-buffer") -- source for text in buffer
	use("hrsh7th/cmp-path") -- source for file system paths

	-- snippets
	use("L3MON4D3/LuaSnip") -- snippet engine
	use("saadparwaiz1/cmp_luasnip") -- for autocompletion
	use("rafamadriz/friendly-snippets") -- useful snippets

	-- managing & installing lsp servers, linters & formatters
	use({
		"williamboman/mason.nvim",
		config = function()
			require("plugins.config.lsp.mason")
		end,
	}) -- in charge of managing lsp servers, linters & formatters

	use({
		"williamboman/mason-lspconfig.nvim",
		after = "mason.nvim",
		config = function()
			require("plugins.config.lsp.mason_lspconfig")
		end,
	}) -- bridges gap between mason & lspconfig

	-- configuring lsp servers
	use({
		"neovim/nvim-lspconfig",
		after = "mason-lspconfig.nvim",
		config = function()
			require("plugins.config.lsp.lspconfig")
		end,
	}) -- easily configure language servers

	use("jose-elias-alvarez/typescript.nvim") -- additional functionality for typescript server (e.g. rename file & update imports)

	use("hrsh7th/cmp-nvim-lsp") -- for autocompletion

	use({
		"glepnir/lspsaga.nvim",
		branch = "main",
		config = function()
			require("plugins.config.lsp.lspsaga")
		end,
	}) -- enhanced lsp uis

	use("onsails/lspkind.nvim") -- vs-code like icons for autocompletion

	-- formatting & linting
	use({
		"jose-elias-alvarez/null-ls.nvim",
		after = "nvim-lspconfig",
		config = function()
			require("plugins.config.lsp.null-ls")
		end,
	}) -- configure formatters & linters

	use({
		"jayp0521/mason-null-ls.nvim",
		after = "null-ls.nvim",
	}) -- bridges gap b/w mason & null-ls

	-- treesitter configuration
	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
		config = function()
			require("plugins.config.treesitter")
		end,
	})

	-- auto closing
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("plugins.config.autopairs")
		end,
	}) -- autoclose parens, brackets, quotes, etc...

	use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" }) -- autoclose tags

	-- git integration
	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("plugins.config.gitsigns")
		end,
	}) -- show line modifications on left hand side

	-- clipboard access
	use({ "ojroques/nvim-osc52" }) -- allows copying text and setting system clipboard

	-- harpoon (file marks)
	use({
		"ThePrimeagen/harpoon",
		requires = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon").setup({
				-- config goes here
			})
		end,
	})

	-- A.I. completion / chatgpt
	-- use("aduros/ai.vim")

	--
	use("MunifTanjim/nui.nvim") -- for ui components used by other plugins

	use({
		"jackMort/ChatGPT.nvim",
		requires = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		after = { "telescope.nvim", "nui.nvim" },
		config = function()
			require("plugins.config.chat-gpt")
		end,
	})

	if packer_bootstrap then
		require("packer").sync()
	end
end)
