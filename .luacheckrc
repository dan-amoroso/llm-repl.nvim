-- Ignore undefined global variables (e.g., Neovim's `vim` object)
globals = { "vim" }

-- Set maximum line length (default: none)
max_line_length = 100

-- Ignore specific warnings (by code)
ignore = { "113", "211" } -- 113: Undefined global, 211: Unused function

-- Allow unused function arguments prefixed with `_`
allow_unused_args = true

-- Exclude specific files or directories
exclude_files = { "lua_modules/**", "tests/**" }
