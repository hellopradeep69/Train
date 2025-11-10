local M = {}

-- Load user options
local opts = require("train.options")

-- Helper to run tmux commands
local function tmux(cmd)
	os.execute("tmux " .. cmd)
end

-- Replace placeholders like %file%, %dir%, %basename%
local function format_cmd(template, vars)
	return (template:gsub("%%(%w+)%%", function(k)
		return vars[k] or "%" .. k .. "%"
	end))
end

-- Run current file in tmux
function M.train()
	local file = vim.fn.expand("%:p")
	local ext = vim.fn.expand("%:e")
	local basename = vim.fn.expand("%:t:r")
	local dir = vim.fn.expand("%:p:h")

	if vim.fn.filereadable(file) == 0 then
		vim.notify("File not found: " .. file, vim.log.levels.ERROR)
		return
	end

	local cmd_template = opts.cmd_map[ext]
	if not cmd_template then
		vim.notify("Unsupported file type: " .. (ext or "unknown"), vim.log.levels.WARN)
		return
	end

	if not os.getenv("TMUX") then
		vim.notify("Not inside a tmux session!", vim.log.levels.ERROR)
		return
	end

	-- Get current tmux session name
	local handle = io.popen("tmux display-message -p '#S'")
	local session_name = handle:read("*a"):gsub("%s+", "")
	handle:close()

	local window_name = opts.window_name or "Train"

	-- Create or select window
	local check = io.popen(string.format("tmux list-windows -t %s | grep -w '%s'", session_name, window_name))
	local exists = check:read("*a")
	check:close()

	if exists == "" then
		tmux(string.format("new-window -t %s -n %s -c '%s'", session_name, window_name, dir))
	else
		tmux(string.format("select-window -t %s:%s", session_name, window_name))
	end

	-- Use make if Makefile exists
	local makefile_exists = vim.fn.filereadable(dir .. "/Makefile") == 1
	local cmd
	if makefile_exists then
		cmd = "make"
	else
		cmd = format_cmd(cmd_template, { file = file, dir = dir, basename = basename })
	end

	-- Escape the ANSI sequences safely for tmux
	local full_cmd = string.format(
		[[clear && printf '\033[33m=== OUTPUT %s ===\033[0m\n'; %s; echo; printf '\033[32m=== DONE ===\033[0m\n'; read]],
		file,
		cmd
	)

	-- Use double quotes around the command so tmux interprets it correctly
	tmux(string.format('send-keys -t %s:%s "%s" C-m', session_name, window_name, full_cmd))
end

function M.setup(user_opts)
	if user_opts then
		for k, v in pairs(user_opts) do
			opts[k] = v
		end
	end
end

return M
