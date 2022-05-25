local present, formatter = pcall(require, "formatter")
if not present then
   return
end

formatter.setup {
 filetype = {
	javascript = {
		-- prettierd
	   function()
		  return {
			exe = "prettierd",
			args = {vim.api.nvim_buf_get_name(0)},
			stdin = true
		  }
		end
	},
	html = {
		-- prettierd
	   function()
		  return {
			exe = "prettierd",
			args = {vim.api.nvim_buf_get_name(0)},
			stdin = true
		  }
		end
	},
	css = {
		-- prettierd
	   function()
		  return {
			exe = "prettierd",
			args = {vim.api.nvim_buf_get_name(0)},
			stdin = true
		  }
		end
	},
	-- javascript = {
	--   -- prettier
	--   function()
	-- 	return {
	-- 	  exe = "prettier",
	-- 	  args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))},
	-- 	  stdin = true
	-- 	}
	--   end
	-- },
  }
}
