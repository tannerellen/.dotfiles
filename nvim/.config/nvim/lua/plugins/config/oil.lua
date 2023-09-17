-- import oil safely
local status, oil = pcall(require, "oil")
if not status then
	return
end

-- configure oil
oil.setup()
