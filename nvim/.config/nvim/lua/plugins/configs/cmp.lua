local present, cmp = pcall(require, "cmp")

if not present then
   return
end

vim.opt.completeopt = "menuone,noselect"

-- nvim-cmp setup
cmp.setup {
   snippet = {
      expand = function(args)
         require("luasnip").lsp_expand(args.body)
      end,
   },
   formatting = {
      format = function(entry, vim_item)
         -- load lspkind icons
         vim_item.kind = string.format(
            "%s %s",
            require("plugins.configs.lspkind_icons").icons[vim_item.kind],
            vim_item.kind
         )

         vim_item.menu = ({
            nvim_lsp = "[LSP]",
            nvim_lua = "[Lua]",
            buffer = "[BUF]",
         })[entry.source.name]

         return vim_item
      end,
   },
   mapping = {
	["<Up>"] = cmp.mapping.select_prev_item(),
    ["<Down>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ["<C-e>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
	  ["<Tab>"] = cmp.mapping(function(fallback)
         if cmp.visible() then
            cmp.select_next_item()
         elseif require("luasnip").expand_or_jumpable() then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
         else
            fallback()
         end
      end, {
         "i",
         "s",
      }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
         if cmp.visible() then
            cmp.select_prev_item()
         elseif require("luasnip").jumpable(-1) then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
         else
            fallback()
         end
      end, {
         "i",
         "s",
      }),

		["<CR>"] = cmp.mapping.confirm { select = true },
		--
		-- ["<Tab>"] = cmp.mapping(function(fallback)
		--   if cmp.visible() then
		-- 	cmp.select_next_item()
		-- 			  elseif luasnip.expand_or_jumpable() then
		-- 	luasnip.expand_or_jump()
		--   elseif has_words_before() then
		-- 	cmp.complete()
		--   else
		-- 	fallback()
		--   end
		-- end, { "i", "s" }),
		--
		-- ["<S-Tab>"] = cmp.mapping(function(fallback)
		--   if cmp.visible() then
		-- 	cmp.select_prev_item()
		-- 			  elseif luasnip.jumpable(-1) then
		-- 	luasnip.jump(-1)
		--   else
		-- 	fallback()
		--   end
		-- end, { "i", "s" }),
		--
   },
   sources = {
      { name = "nvim_lsp", keyword_length = 3, max_item_count = 6 },
      { name = "luasnip" },
      { name = "buffer", keyword_length = 3, max_item_count = 6 },
      { name = "nvim_lua" },
   },
}
