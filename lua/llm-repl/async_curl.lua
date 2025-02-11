local AsyncCurl = {}

local Job = require("plenary.job")

local function async_curl(method, url, options, on_chunk, on_complete)
	Job:new({
		enable_handlers = true,
		command = "curl",
		args = { url, "-d", options.body },
		--cwd = "/usr/bin",
		--env = { ["a"] = "b" },
		on_stderr = function(j, err)
			print(err)
			print(j)
		end,
		on_stdout = on_chunk,
		on_exit = on_complete,
	}):start() -- or start()
end

AsyncCurl.request = async_curl

return AsyncCurl
