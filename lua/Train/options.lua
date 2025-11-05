-- Default options for train.nvim
local options = {
	window_name = "Train",
	clear_before_run = true,
	colors = {
		output = "\27[33m", -- yellow
		done = "\27[32m", -- green
	},
	compilers = {
		py = 'python3 "%s"',
		java = 'javac "%s" && java -cp "%s" "%s"',
		c = 'gcc "%s" -o "%s/%s" && "%s/%s"',
		cpp = 'g++ "%s" -o "%s/%s" && "%s/%s"',
		sh = 'bash "%s"',
		lua = 'lua "%s"',
		js = 'node "%s"',
	},
	post_run_cmd = "read", -- pause after command (can disable by setting to "")
}

return options
