package = "llm-repl.nvim"
version = "dev-1"
source = {
	url = "git+ssh://git@github.com/dan-amoroso/llm-repl.nvim.git",
}
description = {
	detailed = [[
   a neovim plugin to interact with llms like with a repl]],
	homepage = "*** please enter a project homepage ***",
	license = "MIT",
}
dependencies = {
	"lua ~> 5.1",
	"luacheck >= 0.24.0-2",
	"luasocket",
	"dkjson",
}
build = {
	type = "builtin",
	modules = {
		["llm-repl.async_curl"] = "lua/llm-repl/async_curl.lua",
		["llm-repl.init"] = "lua/llm-repl/init.lua",
	},
}
