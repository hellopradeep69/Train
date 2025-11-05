local M = {}

-- Load options
local options = require("train.options")
M.options = options

-- Helper to run tmux commands
local function tmux(cmd)
	os.execute("tmux " .. cmd)
end

-- Run current file in tmux
function M.train(opts)
	if opts then
		M.options = vim.tbl_deep_extend("force", M.options, opts)
	end

	local file = vim.fn.expand("%:p")
	local ext = vim.fn.expand("%:e")
	local basename = vim.fn.expand("%:t:r")
	local dir = vim.fn.expand("%:p:h")

	if vim.fn.filereadable(file) == 0 then
		vim.notify("❌ File not found: " .. file, vim.log.levels.ERROR)
		return
	end

	local cmd_template = M.options.compilers[ext]
	if not cmd_template then
		vim.notify("⚠️ Unsupported file type: " .. (ext or "unknown"), vim.log.levels.WARN)
		return
	end

	local cmd = string.format(cmd_template, file, dir, basename)

	if not os.getenv("TMUX") then
		vim.notify("⚠️ Not inside a tmux session!", vim.log.levels.ERROR)
		return
	end

	local handle = io.popen("tmux display-message -p '#S'")
	local session_name = handle:read("*a"):gsub("%s+", "")
	handle:close()

	local win = M.options.window_name

	-- Kill existing pane (optional)
	tmux(string.format("kill-pane -t %s:%s 2>/dev/null || true", session_name, win))

	local check_handle = io.popen(string.format("tmux list-windows -t %s | grep -w '%s'", session_name, win))
	local exists = check_handle:read("*a")
	check_handle:close()

	if exists == "" then
		tmux(string.format("new-window -t %s -n %s -c '%s'", session_name, win, dir))
	else
		tmux(string.format("select-window -t %s:%s", session_name, win))
	end

	local pre_clear = M.options.clear_before_run and "clear && " or ""
	local output_color = M.options.colors.output
	local done_color = M.options.colors.done
	local pause_cmd = M.options.post_run_cmd

	local final_cmd = string.format(
		[[send-keys -t %s:%s "%s echo '%s === OUTPUT %s === %s' && %s; echo; echo '%s=== DONE ===%s'; %s" C-m]],
		session_name,
		win,
		pre_clear,
		output_color,
		file,
		"\27[0m",
		cmd,
		done_color,
		"\27[0m",
		pause_cmd
	)

	tmux(final_cmd)
end

-- Setup function for external configuration
function M.setup(opts)
	if opts then
		M.options = vim.tbl_deep_extend("force", M.options, opts)
	end
end

return M
