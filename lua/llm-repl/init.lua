local M = {}

M.config = {
	api_url = "hq.local:11434/api/generate",
	buf_name = "_ChatBuffer",
}

-- append multiline strings to buffer
local function append_to_buffer(buf_nr, multiline_text)
	local lines = {}
	for line in multiline_text:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	local line_count = vim.api.nvim_buf_line_count(buf_nr)

	vim.api.nvim_buf_set_lines(buf_nr, line_count, line_count, false, lines)
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
local function send_to_llm(prompt)
	local http = require("plenary.curl")
	local response = http.post(M.config.api_url, {
		body = vim.fn.json_encode({ prompt = prompt, model = M.config.model, stream = M.config.stream }),
		headers = { ["Content-Type"] = "application/json" },
		timeout = 100000,
	})

	return response
end

function M.prompt()
	local prompt = get_selection()
	if prompt == "" then
		print("llm-repl: No text selected")
		return
	end

	local buf = find_or_create_buffer()

	append_to_buffer(buf, "User: \n" .. prompt .. "\n\n")

	local response = send_to_llm(prompt)

	append_to_buffer(buf, "Response: \n" .. response.body .. "\n\n")
end

function M.open_chat()
	vim.api.nvim_set_current_buf(find_or_create_buffer())
end

function M.setup()
	vim.api.nvim_set_keymap(
		"v",
		"<leader>ll",
		":lua require('llm-repl').prompt()<CR>",
		{ noremap = true, desc = "llm-repl: send selection as prompt" }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<leader>lc",
		":lua require('llm-repl').open_chat()<CR>",
		{ noremap = true, desc = "llm-repl: open chat buffer" }
	)
end
