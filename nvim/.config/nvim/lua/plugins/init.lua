local present, packer = pcall(require, "plugins.packerInit")

if not present then
   return false
end

local use = packer.use

return packer.startup(function()

   -- this is arranged on the basis of when a plugin starts

   use {
      "nvim-lua/plenary.nvim",
   }

   use {
      "wbthomason/packer.nvim",
      event = "VimEnter",
   }

   use {
   	   "tannerellen/nvim-base16",
   	   after = "packer.nvim",
   	   config = function()
   		   require("colors").init()
       end,	
   }

   -- use {
   --    "NvChad/nvim-base16.lua",
   --    after = "packer.nvim",
   --    config = function()
   --       require("colors").init()
   --    end,
   -- }

	-- "ellisonleao/gruvbox.nvim",
	-- use { 
	-- after = "packer.nvim",
	--       config = function()
	--          require("colors").init()
	--       end,
	--    }

   use {
      "kyazdani42/nvim-web-devicons",
      after = "nvim-base16",
      config = function()
         require "plugins.configs.icons"
      end,
   }

   use {
      "feline-nvim/feline.nvim",
	  branch = "master",
      after = "nvim-web-devicons",
      config = function()
         require "plugins.configs.statusline"
      end,
   }

   -- use {
   --    "akinsho/bufferline.nvim",
   -- 	  branch = "main",
   --    after = "nvim-web-devicons",
   --    config = function()
   --       require "plugins.configs.bufferline"
   --    end,
   --    setup = function()
   --       require("core.mappings").bufferline()
   --    end,
   -- }
   --
   use {
      "lukas-reineke/indent-blankline.nvim",
      event = "BufRead",
      config = function()
         require("plugins.configs.others").blankline()
      end,
   }

   use {
      "norcalli/nvim-colorizer.lua",
      event = "BufRead",
      config = function()
         require("plugins.configs.others").colorizer()
      end,
   }

   use {
      "nvim-treesitter/nvim-treesitter",
	  run = ':TSUpdate',
      event = "BufRead",
      config = function()
       require "plugins.configs.treesitter"
      end,
   }

   -- git stuff
   use {
      "lewis6991/gitsigns.nvim",
      -- opt = true,
	  requires = 'nvim-lua/plenary.nvim',
      after = "nvim-web-devicons",
      config = function()
         require "plugins.configs.gitsigns"
      end,
   }


   -- -- lsp stuff
   use {
   	  "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
   }

   use {
      "neovim/nvim-lspconfig",
   	  requires = "mason-lspconfig.nvim",
      config = function()
         require "plugins.configs.lspconfig"
      end,
   }
  
   use {
      "ray-x/lsp_signature.nvim",
      after = "nvim-lspconfig",
      config = function()
         require("plugins.configs.others").signature()
      end,
   }

   use {
      "andymass/vim-matchup",
      opt = true,
   }

   -- load luasnips + cmp related in insert mode only

   use {
      "rafamadriz/friendly-snippets",
	  event = "InsertEnter",
   }

   use {
      "hrsh7th/nvim-cmp",
	  after = "friendly-snippets",
      config = function()
         require "plugins.configs.cmp"
      end,
   }

   use {
      "L3MON4D3/LuaSnip",
      wants = "friendly-snippets",
      after = "nvim-cmp",
      config = function()
         require("plugins.configs.others").luasnip()
      end,
   }

   use {
      "saadparwaiz1/cmp_luasnip",
      after = "LuaSnip",
   }

   use {
      "hrsh7th/cmp-nvim-lua",
      after = "cmp_luasnip",
   }

   use {
      "hrsh7th/cmp-nvim-lsp",
      after = "cmp-nvim-lua",
   }

   use {
      "hrsh7th/cmp-buffer",
      after = "cmp-nvim-lsp",
   }
   
   use {
      "hrsh7th/cmp-path",
      after = "cmp-nvim-lsp",
   }

   -- misc plugins
   use {
      "windwp/nvim-autopairs",
      after = "nvim-cmp",
      config = function()
         require("plugins.configs.others").autopairs()
      end,
   }

   use {
	   "mhartington/formatter.nvim",
	   event = "BufRead",
	   setup = function()
	   		   require("core.mappings").formatter()
	   end,
	   config = function()
		   require "plugins.configs.formatter"
	   end,
   }

   --   use "alvan/vim-closetag" -- for html autoclosing tag
   use {
      "terrortylor/nvim-comment",
      cmd = "CommentToggle",
      config = function()
         require("plugins.configs.others").comment()
      end,
      setup = function()
         require("core.mappings").comment()
      end,
   }

   -- file managing , picker etc
   use {
      "kyazdani42/nvim-tree.lua",
      cmd = { "NvimTreeToggle", "NvimTreeFocus" },
      config = function()
         require "plugins.configs.nvimtree"
      end,
      setup = function()
         require("core.mappings").nvimtree()
      end,
   }

   use {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      requires = {
		 {
			 "nvim-lua/plenary.nvim"
	 	 },
      },
      config = function()
         require "plugins.configs.telescope"
      end,
      setup = function()
         require("core.mappings").telescope()
      end,
   }

   -- Linux utility commands in neovim (create directory and files)
   -- use {
   -- 	   "tpope/vim-eunuch"
   -- }

   use {
   	   "f-person/git-blame.nvim",
      setup = function()
         require("plugins.configs.others").git_blame()
         require("core.mappings").git_blame()
      end,
   
   }

   -- smooth scroll
   use {
      "karb94/neoscroll.nvim",
      opt = true,
      after = "packer.nvim",
      config = function()
         require("plugins.configs.others").neoscroll()
      end,
   }

   use {
      "ThePrimeagen/harpoon",
      requires = {
		 {
			 "nvim-lua/plenary.nvim"
	 	 },
      },
      setup = function()
         require("core.mappings").harpoon()
      end,
   }
	
   use {'ojroques/nvim-osc52'}

end)

