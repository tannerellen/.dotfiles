local present, ts_config = pcall(require, "nvim-treesitter.configs")
if not present then
   return
end

ts_config.setup {
   ensure_installed = {
	 "css",
	 "html",
	 "javascript",
	 "json",
     "lua",
	 "typescript",
	 "php",
	 "scss",
	 "tsx",
	 "jsdoc",
   },
   highlight = {
      enable = true,
	  disable = { "css" },
      use_languagetree = true,
   },
   indent = {
	   enabled = false, -- default is disabled anyways
   }
}
