-- lua/Train/options.lua
local M = {}

-- Default configuration
M.window_name = "Train"

M.cmd_map = {
	py = 'python3 "%file%"',
	java = 'javac "%file%" && java -cp "%dir%" "%basename%"',
	c = 'gcc "%file%" -o "%dir%/%basename%" && "%dir%/%basename%"',
	cpp = 'g++ "%file%" -o "%dir%/%basename%" && "%dir%/%basename%"',
	sh = 'bash "%file%"',
	lua = 'lua "%file%"',
	js = 'node "%file%"',
}

return M
