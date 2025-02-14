local AsyncCurl = {}

local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")

local function async_curl(method, url, options, on_chunk, on_complete)
	local res, code, headers, status = http.request({
		url = url,
		method = method,
		headers = { ["Content-Type"] = "applicatin/json" },
		source = ltn12.source.string(options.body),
		sink = on_chunk,
	})

	print(res, code, headers, status)
end

AsyncCurl.request = async_curl

return AsyncCurl
