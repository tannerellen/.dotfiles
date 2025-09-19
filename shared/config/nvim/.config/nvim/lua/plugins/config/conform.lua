-- import conform formatter plugin safely
local status, conform = pcall(require, "conform")
if not status then
	print("conform did not load")
	return
end

-- setup conform plugin
conform.setup({
	formatters_by_ft = {
		-- lua
		lua = { "stylua" },
		-- base web formats (use a sub-list to run only the first available formatter)
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		-- svelte
		svelte = { "prettierd", "prettier", stop_after_first = true },
		-- react
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		-- json
		json = { "prettierd", "prettier", stop_after_first = true },
		-- everything else will use lsp format
	},
	-- enable format on save
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 4000,
		lsp_fallback = true,
	},
})
