local M = {}

-- TODO: these should not need to be here, can we make it work in the setup?
-- TODO: also need to be using the autodetected plugin path
local deps_path = "/Users/dan/workspace/llm-repl.nvim/lua_modules/share/lua/5.1/?.lua" -- plugin_dir .. "lua_modules/share/lua/5.1/?.lua"
local deps_cpath = "/Users/dan/workspace/llm-repl.nvim/lua_modules/lib/lua/5.1/?.so" -- plugin_dir .. "lua_modules/lib/lua/5.1/?.so"
package.path = package.path .. ";" .. deps_path
package.cpath = package.cpath .. ";" .. deps_cpath

local chat = require("llm-repl.buffer")

local json = require("dkjson")
local config = {
	api_url = "http://localhost:11434/api/generate",
	model = "deepseek-coder-v2",
	timeout = 200000,
	stream = true,
}

local function region_to_text(region)
	local text = ""
	local maxcol = vim.v.maxcol
	for line, cols in vim.spairs(region) do
		local endcol = cols[2] == maxcol and -1 or cols[2]
		local chunk = vim.api.nvim_buf_get_text(0, line, cols[1], line, endcol, {})[1]
		text = ("%s%s\n"):format(text, chunk)
	end
	return text
end

local function get_selection()
	local r = vim.region(0, "'<", "'>", vim.fn.visualmode(), true)
	return region_to_text(r)
end

function sink_to_chat(data)
	local decoded = json.decode(data)
	chat.append(decoded.response)
end

-- post prompts to LLM
local function send_to_llm(prompt, callback)
	local http = require("llm-repl.async_curl")
	http.request("POST", config.api_url, {
		body = vim.fn.json_encode({
			prompt = prompt,
			model = config.model,
			stream = config.stream,
		}),
		timeout = config.timeout,
	}, callback, callback)
end

function M.prompt()
	local prompt = get_selection()
	if prompt == "" then
		print("llm-repl: No text selected")
		return
	end

	chat.append(prompt)

	send_to_llm(prompt, sink_to_chat)
end

function M.open_chat()
	vim.api.nvim_set_current_buf(chat.get_buffer())
end

function M.open_windowed()
	print(chat.get_buffer())
	vim.api.nvim_open_win(chat.get_buffer(), false, { split = "right", win = -1, style = "minimal" })
end

function M.setup()
	vim.api.nvim_set_keymap(
		"v",
		"<leader>lll",
		":lua require('llm-repl').prompt()<CR>",
		{ noremap = true, desc = "llm-repl: send selection as prompt", silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<leader>llc",
		":lua require('llm-repl').open_chat()<CR>",
		{ noremap = true, desc = "llm-repl: open chat buffer", silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<leader>llv",
		":lua require('llm-repl').open_windowed()<CR>",
		{ noremap = true, desc = "llm-repl: chat in a separate vim window", silent = true }
	)
end

return M
