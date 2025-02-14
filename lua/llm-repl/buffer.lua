local M = {}

M.append = function(multiline_text)
	local b = M.get_buffer()
	local lines = {}
	if multiline_text then
		for line in multiline_text:gmatch("[^\r\n]+") do
			table.insert(lines, line)
		end
	end

	vim.schedule(function()
		local line_count = vim.api.nvim_buf_line_count(b)
		vim.api.nvim_buf_set_lines(b, line_count, line_count, false, lines)
	end)
end

M.get_buffer = function()
	local buf = vim.fn.bufnr("chat_buffer", true)

	return buf
end

return M
