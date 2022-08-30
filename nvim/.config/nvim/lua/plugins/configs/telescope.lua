local present, telescope = pcall(require, "telescope")
if not present then
   return
end

telescope.setup {
   defaults = {
      vimgrep_arguments = {
         "rg",
         "--color=never",
         "--no-heading",
         "--with-filename",
         "--line-number",
         "--column",
         "--smart-case",
      },
      prompt_prefix = "   ",
      selection_caret = "  ",
      entry_prefix = "  ",
      initial_mode = "insert",
      selection_strategy = "reset",
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
         horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
         },
         vertical = {
            mirror = false,
         },
         width = 0.87,
         height = 0.80,
         preview_cutoff = 120,
      },
	   preview = {
   		   treesitter = false, -- Disable treesitter in the preview window so large files don't hang
		   filesize_limit = 0.1,
		   timeout = 250,
	   },
      file_sorter = require("telescope.sorters").get_fuzzy_file,
      file_ignore_patterns = {"node_modules"},
      generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
      path_display = { "truncate" }, -- hidden, tail, absolute, smart, shorten, truncate (truncate can = a number like "truncate = 3") 
      winblend = 0,
      border = {},
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      color_devicons = true,
      use_less = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      -- Developer configurations: Not meant for general override
      buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,

   },
   pickers = {
      buffers = {
         initial_mode = "normal",
		     -- config_key = value,
         mappings = {
            n = {
               -- map actions.which_key to <C-h> (default: <C-/>)
               -- actions.which_key shows the mappings for your picker,
               -- e.g. git_{create, delete, ...}_branch for the git_branches picker
	           ["d"] = require("telescope.actions").delete_buffer
		    }
         }
      }
   },
}

local extensions = { "themes", "terms"}

pcall(function()
   for _, ext in ipairs(extensions) do
      telescope.load_extension(ext)
   end
end)
