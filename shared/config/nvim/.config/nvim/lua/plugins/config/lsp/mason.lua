-- import mason plugin safely
local mason_status, mason = pcall(require, "mason")
if not mason_status then
	print("mason did not load")
	return
end

-- enable mason
mason.setup()

-- import mason-lspconfig plugin safely
local mason_lsp_config_status, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lsp_config_status then
	print("mason-lspconfig did not load")
	return
end

mason_lspconfig.setup({
	-- list of servers for mason to install
	ensure_installed = {
		"tsserver",
		"html",
		"cssls",
		"lua_ls",
		"svelte",
		"bashls",
		"marksman",
		"jsonls",
		"yamlls",
		-- "emmet_ls",
	},
	-- auto-install configured servers (with lspconfig)
	automatic_installation = true, -- not the same as ensure_installed
})

-- import mason-tool-installer plugin safely
local mason_tool_installer_status, mason_tool_installer = pcall(require, "mason-tool-installer")
if not mason_tool_installer_status then
	print("mason-tool-installer did not load")
	return
end

-- enable mason tool installer
mason_tool_installer.setup({
	ensure_installed = {
		"prettierd",
		"stylua",
	},
})
