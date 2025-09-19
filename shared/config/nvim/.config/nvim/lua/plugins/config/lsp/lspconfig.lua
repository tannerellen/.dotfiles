-- import lspconfig plugin safely
local lspconfig_status, lspconfig = pcall(require, "vim.lsp.config")
if not lspconfig_status then
	print("lspconfig did not load")
	return
end

-- import cmp-nvim-lsp plugin safely
-- local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
-- if not cmp_nvim_lsp_status then
-- 	print("cmp-nvim-lsp did not load")
-- 	return
-- end
local blink_cmp_status, blink_cmp = pcall(require, "blink.cmp")
if not blink_cmp_status then
	print("blink.cmp did not load")
	return
end

-- import typescript tools safely (an alternative to typescript-server)
local typescript_tools_status, typescript_tools = pcall(require, "typescript-tools")
if not typescript_tools_status then
	print("typescript-tools did not load")
	return
end

-- get a reference to keymaps
local keymaps = require("core.keymaps")

-- enable keybinds only for when lsp server available
local on_attach = function(client, bufnr)
	-- assign keymaps meant for lsp features
	keymaps.lsp_on_attach(bufnr)

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
end

-- used to enable autocompletion (assign to every lsp server config)
-- local capabilities = cmp_nvim_lsp.default_capabilities()
local capabilities = blink_cmp.get_lsp_capabilities()

-- Removed because it is replaced with built in vim.diagnostic. Can remove once we no longer need for reference (when things are proved to work)
-- -- Change the Diagnostic symbols in the sign column (gutter)
-- local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
-- -- local signs = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }
-- for type, icon in pairs(signs) do
-- 	local hl = "DiagnosticSign" .. type
-- 	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
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

local debounce = 150

-- configure typescript server with plugin
typescript_tools.setup({
	filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	capabilities = capabilities,
	on_attach = on_attach,
	flags = {
		debounce_text_changes = debounce,
	},
	settings = {
		-- spawn additional tsserver instance to calculate diagnostics on it
		separate_diagnostic_server = false,
	},
})

-- Set up LSP servers with the same config
local servers = { "html", "cssls", "svelte", "bashls", "jsonls", "yamlls" }
for _, lsp in pairs(servers) do
	require("lspconfig")[lsp].setup({
		capabilities = capabilities,
		on_attach = on_attach,
		flags = {
			debounce_text_changes = debounce,
		},
	})
end

-- configure emmet language server
-- lspconfig["emmet_ls"].setup({
-- 	capabilities = capabilities,
-- 	on_attach = on_attach,
-- 	filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
-- 	root_dir = function()
-- 		return vim.loop.cwd()
-- 	end,
-- })

-- configure marksman specifically because if file types aren't specified it will attach to lspsaga dialogs
lspconfig.marksman.setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "markdown", "markdown.mdx" },
	flags = {
		debounce_text_changes = debounce,
	},
})

-- configure lua server (with special settings)
lspconfig["lua_ls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	flags = {
		debounce_text_changes = debounce,
	},
	settings = { -- custom settings for lua
		Lua = {
			-- make the language server recognize "vim" global
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				-- make language server aware of runtime files
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
	root_dir = function()
		return vim.loop.cwd()
	end,
})
