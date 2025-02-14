local M = {}

M.config = {
	api_url = "http://localhost:11434/api/generate",
	model = "deepseek-coder-v2",
	timeout = 200000,
	stream = false,
}

return M
