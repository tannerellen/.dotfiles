-- import oil safely
local status, oil = pcall(require, "oil")
if not status then
	print("oil did not load")
	return
end

-- configure oil
oil.setup({
	view_options = {
		show_hidden = true,
		is_always_hidden = function(name, _)
			return name == ".."
		end,
	},
})
