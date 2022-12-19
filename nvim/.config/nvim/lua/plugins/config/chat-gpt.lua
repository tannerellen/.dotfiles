-- import plugin safely
local setup, chat_gpt = pcall(require, "chatgpt")
if not setup then
	return
end

chat_gpt.setup({
	-- optional configuration
})
