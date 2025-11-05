local M = {}

-- Helper: safely execute tmux commands
local function tmux(cmd)
	os.execute(string.format("tmux %s", cmd))
end

-- Run the current file in tmux
function M.train()
	local file = vim.fn.expand("%:p")
	local ext = vim.fn.expand("%:e")
	local basename = vim.fn.expand("%:r")
	local class = vim.fn.expand("%:t:r")
	local dir = vim.fn.expand("%:p:h")

	if vim.fn.filereadable(file) == 0 then
		vim.notify("❌ File not found: " .. file, vim.log.levels.ERROR)
		return
	end

	local cmd = ""

	-- 🧱 Detect Makefile
	if vim.fn.filereadable(dir .. "/Makefile") == 1 or vim.fn.filereadable(dir .. "/makefile") == 1 then
		cmd = string.format('cd "%s" && make && echo "\\n=== OUTPUT ===" && ./"%s"', dir, class)
	else
		-- 🧠 Detect language
		local map = {
			py = string.format('python3 "%s"', file),
			java = string.format('javac "%s" && java "%s"', file, class),
			c = string.format('gcc "%s" -o "%s" && ./"%s"', file, basename, basename),
			cpp = string.format('g++ "%s" -o "%s" && ./"%s"', file, basename, basename),
			sh = string.format('bash "%s"', file),
			lua = string.format('lua "%s"', file),
			js = string.format('node "%s"', file),
		}
		cmd = map[ext]
	end

	if not cmd or cmd == "" then
		vim.notify("⚠️ Unsupported file type: " .. (ext or "unknown"), vim.log.levels.WARN)
		return
	end

	vim.notify("🚀 Running " .. file .. " in tmux window [coderun]", vim.log.levels.INFO)

	-- 🪟 Ensure tmux window "coderun" exists or create it
	local check = os.execute("tmux has-session -t coderun 2>/dev/null")
	if check ~= 0 then
		os.execute("tmux new-session -d -s coderun")
	end

	-- 🧰 Send commands to tmux window
	tmux(
		string.format(
			[[send-keys -t coderun "clear && echo '▶ Running %s...' && %s; echo; echo '=== DONE ==='; read" C-m]],
			file,
			cmd
		)
	)
	tmux("select-window -t coderun")
end

-- 🗝️ Keymap: <leader>R
vim.keymap.set(
	"n",
	"<leader>R",
	M.train,
	{ noremap = true, silent = true, desc = "Run current file in tmux (coderun)" }
)

return M
