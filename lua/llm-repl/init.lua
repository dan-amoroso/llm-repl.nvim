local M = {}
local async = require("plenary.async")
--hello
M.config = {
	api_url = "http://localhost:11434/api/generate",
	model = "deepseek-coder-v2",
	timeout = 200000,
	stream = false,
	buf_name = "_ChatBuffer",
}

--is this idiomatic lua for neovim?
-- append multiline strings to buffer
local function append_to_buffer(buf_nr, multiline_text)
	local lines = {}
	if multiline_text then
		for line in multiline_text:gmatch("[^\r\n]+") do
			table.insert(lines, line)
		end
	end

	vim.schedule(function()
		local line_count = vim.api.nvim_buf_line_count(buf_nr)
		vim.api.nvim_buf_set_lines(buf_nr, line_count, line_count, false, lines)
	end)
end

-- get text currently under visual selection
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

-- create or find chat buffer
local function find_or_create_buffer()
	local buf = vim.fn.bufnr(M.config.buf_name)

	if buf == -1 then
		buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(buf, M.config.buf_name)
	end

	return buf
end

-- post prompts to LLM
local function send_to_llm(prompt, callback)
	local http = require("llm-repl.async_curl")
	http.request("POST", M.config.api_url, {
		body = vim.fn.json_encode({
			prompt = prompt,
			model = M.config.model,
			stream = M.config.stream,
		}),
		timeout = M.config.timeout,
	}, nil, callback)
end

function M.prompt()
	local prompt = get_selection()
	if prompt == "" then
		print("llm-repl: No text selected")
		return
	end

	local buf = find_or_create_buffer()

	append_to_buffer(buf, " ")
	append_to_buffer(buf, prompt)
	append_to_buffer(buf, " ")

	send_to_llm(prompt, function(err, body)
		if not err then
			local success, decoded = pcall(vim.fn.json_decode(body))
			if not success then
				append_to_buffer(buf, "failed to parse")
			else
				append_to_buffer(buf, decoded)
				append_to_buffer(buf, decoded.response or "nil")
			end
		else
			append_to_buffer(buf, err)
		end
	end)
end

function M.open_chat()
	vim.api.nvim_set_current_buf(find_or_create_buffer())
end

function M.open_windowed()
	vim.api.nvim_open_win(find_or_create_buffer(), false, { split = "right", win = -1, style = "minimal" })
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
