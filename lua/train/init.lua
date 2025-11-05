-- lua/Train/init.lua
local M = {}

-- Load user options
local opts = require("train.options") -- load options.lua

-- Helper to run tmux commands
local function tmux(cmd)
	os.execute("tmux " .. cmd)
end

-- Replace placeholders in cmd string
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

	local handle = io.popen("tmux display-message -p '#S'")
	local session_name = handle:read("*a"):gsub("%s+", "")
	handle:close()

	local window_name = opts.window_name

	-- Kill pane if exists (optional)
	tmux(string.format("kill-pane -t %s:%s 2>/dev/null || true", session_name, window_name))

	-- Check if window exists
	local check_handle = io.popen(string.format("tmux list-windows -t %s | grep -w '%s'", session_name, window_name))
	local exists = check_handle:read("*a")
	check_handle:close()

	if exists == "" then
		tmux(string.format("new-window -t %s -n %s -c '%s'", session_name, window_name, dir))
	else
		tmux(string.format("select-window -t %s:%s", session_name, window_name))
	end

	-- Format command
	local cmd = format_cmd(cmd_template, { file = file, dir = dir, basename = basename })

	local tmp_script = dir .. "/.train_tmp.sh"
	local f = io.open(tmp_script, "w")
	f:write(string.format(
		[[
#!/bin/bash
clear
echo -e '\e[33m === OUTPUT %s ===\e[0m'
%s
echo
]],
		file,
		cmd
	))
	f:close()
	os.execute("chmod +x " .. tmp_script)

	-- Then send to tmux:
	tmux(string.format("send-keys -t %s:%s '%s' C-m", session_name, window_name, tmp_script))

	-- Send to tmux
	-- tmux(
	-- 	string.format(
	-- 		[[send-keys -t %s:%s "clear && echo '\e[33m === OUTPUT %s ===\e[0m' && %s; echo; echo '\e[32m=== DONE ===\e[0m'; read" C-m]],
	-- 		session_name,
	-- 		window_name,
	-- 		file,
	-- 		cmd
	-- 	)
	-- )
end

-- At the end of init.lua
function M.setup(user_opts)
	if user_opts then
		for k, v in pairs(user_opts) do
			opts[k] = v
		end
	end
end

return M
