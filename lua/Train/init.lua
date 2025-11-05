local M = {}

-- Helper to run tmux commands
local function tmux(cmd)
	os.execute("tmux " .. cmd)
end

-- Run current file in tmux, reuse window if exists
function M.train()
	local file = vim.fn.expand("%:p")
	local ext = vim.fn.expand("%:e")
	local basename = vim.fn.expand("%:t:r") -- just the file name without extension
	local dir = vim.fn.expand("%:p:h")

	if vim.fn.filereadable(file) == 0 then
		vim.notify("❌ File not found: " .. file, vim.log.levels.ERROR)
		return
	end

	-- Command map by file type
	local cmd_map = {
		py = string.format('python3 "%s"', file),
		java = string.format('javac "%s" && java -cp "%s" "%s"', file, dir, basename),
		c = string.format('gcc "%s" -o "%s/%s" && "%s/%s"', file, dir, basename, dir, basename),
		cpp = string.format('g++ "%s" -o "%s/%s" && "%s/%s"', file, dir, basename, dir, basename),
		sh = string.format('bash "%s"', file),
		lua = string.format('lua "%s"', file),
		js = string.format('node "%s"', file),
	}

	local cmd = cmd_map[ext]
	if not cmd then
		vim.notify("⚠️ Unsupported file type: " .. (ext or "unknown"), vim.log.levels.WARN)
		return
	end

	-- Make sure we are inside tmux
	if not os.getenv("TMUX") then
		vim.notify("⚠️ Not inside a tmux session!", vim.log.levels.ERROR)
		return
	end

	-- Get current tmux session
	local handle = io.popen("tmux display-message -p '#S'")
	local session_name = handle:read("*a"):gsub("%s+", "")
	handle:close()

	-- Window name
	local window_name = "Train"

	-- Kill existing pane if you want (optional)
	tmux(string.format("kill-pane -t %s:%s 2>/dev/null || true", session_name, window_name))

	-- Check if window exists
	local check_handle = io.popen(string.format("tmux list-windows -t %s | grep -w '%s'", session_name, window_name))
	local exists = check_handle:read("*a")
	check_handle:close()

	if exists == "" then
		-- Create window in current path
		tmux(string.format("new-window -t %s -n %s -c '%s'", session_name, window_name, dir))
	else
		-- Select existing window
		tmux(string.format("select-window -t %s:%s", session_name, window_name))
	end

	-- Send command to tmux window
	tmux(
		string.format(
			[[send-keys -t %s:%s "clear && echo '\e[33m▶ Running %s...\e[0m' && %s; echo; echo '\e[32m=== DONE ===\e[0m'; read" C-m]],
			session_name,
			window_name,
			file,
			cmd
		)
	)

	vim.notify("🚀 Running " .. file .. " in tmux window [" .. window_name .. "]", vim.log.levels.INFO)
end

-- Keymap
vim.keymap.set("n", "<leader>R", M.train, { noremap = true, silent = true, desc = "Run current file in tmux (Train)" })

return M
