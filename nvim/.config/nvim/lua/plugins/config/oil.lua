-- import oil safely
local status, oil = pcall(require, "oil")
if not status then
	print("oil did not load")
	return
end

-- configure oil
oil.setup()
