-- enable keybinds only for when lsp server available
-- local on_attach = function(client, bufnr)
-- assign keymaps meant for lsp features
-- keymaps.lsp_on_attach(bufnr)

-- If this is a svelte client work-around for failed file watching
-- https://github.com/sveltejs/language-tools/issues/2008
-- if client.name == "svelte" then
-- 	vim.api.nvim_create_autocmd({ "BufWritePre" }, {
-- 		pattern = { "*.js", "*.ts" },
-- 		callback = function(ctx)
-- 			client:notify("$/onDidChangeTsOrJsFile", {
-- 				uri = ctx.match,
-- 			})
-- 		end,
-- 	})
-- end
-- end

-- Setting severity_sort to fix a bug in lspsaga. Once that bug is fixed can remove
-- https://github.com/nvimdev/lspsaga.nvim/issues/1520
local x = vim.diagnostic.severity
vim.diagnostic.config({
	severity_sort = true,
	virtual_text = { prefix = "" },
	signs = { text = { [x.ERROR] = " ", [x.WARN] = " ", [x.INFO] = " ", [x.HINT] = " " } },
	underline = true,
	float = { border = "single" },
})

-- get a reference to keymaps
local keymaps = require("core.keymaps")
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local bufnr = ev.buf
		keymaps.lsp_on_attach(bufnr)
	end,
})

vim.lsp.config("vtsls", {
	flags = { debounce_text_changes = 150 },
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = {
					"vim",
					"require",
				},
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})
