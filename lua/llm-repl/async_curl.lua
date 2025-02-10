local uv = vim.loop

local AsyncCurl = {}

local http = require("plenary.curl")

-- can you help me make this function async so it won't stop the nvim main thread?
-- please keep the reasoning short

local function http_request(method, url, body, headers, timeout, callback)
	print(method, url, body, vim.fn.json_encode(headers), callback)
	local response = http.request({
		method = method,
		url = url,
		body = body,
		headers = headers or {},
		timeout = timeout,
	})

	if response.status ~= 200 then
		callback(nil, "HTTP Error: " .. response.status)
	else
		callback(vim.fn.json_decode(response.body), nil)
	end
end

local function async_curl(method, url, options, on_chunk, on_complete)
	-- TODO: create coroutine to execute the http request to avoid locking nvim
	http_request(method, url, options.body, options.headers, options.timeout, on_chunk)
	on_complete()
end

AsyncCurl.post = async_curl

return AsyncCurl
