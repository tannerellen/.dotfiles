local M = {}
local g = vim.g

M.autopairs = function()
   local present1, autopairs = pcall(require, "nvim-autopairs")
   local present2, autopairs_completion = pcall(require, "nvim-autopairs.completion.cmp")

   if not (present1 or present2) then
      return
   end

   autopairs.setup()
   -- autopairs_completion.setup {
   --    map_complete = true, -- insert () func completion
   --    map_cr = true,
   -- }
end

-- M.better_escape = function()
-- 	local m = require("core.mappings").better_escape()
--    require("better_escape").setup {
-- 	   mapping = m,
-- 	   timeout = 300,
--    }
-- end

M.git_blame = function()
	-- Don't show git blame by default. Can toggle on and off with :GitBlameToggle
	g.gitblame_enabled = 0
end

M.blankline = function()
   require("indent_blankline").setup {
      indentLine_enabled = 1,
      char = "▏",
      filetype_exclude = {
         "help",
         "terminal",
         "dashboard",
         "packer",
         "lspinfo",
         "TelescopePrompt",
         "TelescopeResults",
		 "",
      },
      buftype_exclude = { "terminal" },
      show_trailing_blankline_indent = false,
      show_first_indent_level = false,
   }
end

M.colorizer = function()
   local present, colorizer = pcall(require, "colorizer")
   if present then
      colorizer.setup({ "*" }, {
         RGB = true, -- #RGB hex codes
         RRGGBB = true, -- #RRGGBB hex codes
         names = false, -- "Name" codes like Blue
         RRGGBBAA = false, -- #RRGGBBAA hex codes
         rgb_fn = false, -- CSS rgb() and rgba() functions
         hsl_fn = false, -- CSS hsl() and hsla() functions
         css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
         css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn

         -- Available modes: foreground, background
         mode = "background", -- Set the display mode.
      })
      vim.cmd "ColorizerReloadAllBuffers"
   end
end

M.comment = function()
   local present, nvim_comment = pcall(require, "nvim_comment")
   if present then
      nvim_comment.setup()
   end
end

M.lsp_installer = function()
	local present, lsp_installer = pcall(require, "nvim-lsp-installer")
	if not present then
		return
	end

	lsp_installer.on_server_ready(function(server)
		local opts = {}

		-- (optional) Customize the options passed to the server
		-- if server.name == "tsserver" then
		--     opts.root_dir = function() ... end
		-- end

		-- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
		server:setup(opts)
		vim.cmd [[ do User LspAttachBuffers ]]
	end)
end

M.luasnip = function()
   local present, luasnip = pcall(require, "luasnip")
   if not present then
      return
   end

   luasnip.config.set_config {
      history = true,
      updateevents = "TextChanged,TextChangedI",
   }
   require("luasnip/loaders/from_vscode").load()
end

M.neoscroll = function()
   pcall(function()
      require("neoscroll").setup()
   end)
end

M.signature = function()
   local present, lspsignature = pcall(require, "lsp_signature")
   if present then
      lspsignature.setup {
         bind = true,
         doc_lines = 2,
         floating_window = true,
         fix_pos = true,
         hint_enable = true,
         hint_prefix = " ",
         hint_scheme = "String",
         hi_parameter = "Search",
         max_height = 22,
         max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
         handler_opts = {
            border = "single", -- double, single, shadow, none
         },
         zindex = 200, -- by default it will be on top of all floating windows, set to 50 send it to bottom
         padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc
      }
   end
end

return M
