-- main module
local M = {}

local DATA = vim.fn.stdpath("data") .. "/Train"
vim.fn.mkdir(DATA, "p")

function project_name()
	return vim.uv.cwd():gsub("^/", "_"):gsub("/", "_")
end

function file_list()
	return DATA .. "/" .. project_name() .. ".txt"
end

-- args added
function M.add()
	local path = vim.fn.expand("%:p")

	local list_path = file_list()
	local entries = {}

	if vim.fn.filereadable(list_path) == 1 then
		entries = vim.fn.readfile(list_path)
	end

	-- dedupe
	for _, v in ipairs(entries) do
		if v == path then
			return
		end
	end

	table.insert(entries, path)
	vim.fn.writefile(entries, list_path)
	M.load()

	vim.notify("Added: " .. vim.fn.fnamemodify(path, ":t"))
end

-- list args
function M.list()
	M.load()
	local args = vim.fn.argv()
	local filenames = {}

	for i, arg in ipairs(args) do
		table.insert(filenames, i .. "-" .. arg)
	end

	print(table.concat(filenames, " "))
end

-- go to arg num i.e arg1
function M.get(num)
	vim.cmd.argu(num)
	-- vim.cmd.args()
end

-- next
function M.next()
	vim.cmd.next()
end

-- prev
function M.prev()
	vim.cmd.prev()
end

-- TODO: write
function M.load()
	local file = io.open(file_list(), "r")

	if not file then
		vim.notify("something wrong")
		return
	end

	vim.cmd("%argdelete")

	for line in file:lines() do
		pcall(function()
			vim.cmd.arge(line)
			vim.cmd.argded()
		end)
	end

	file:close()
	vim.cmd.e()
end

function M.edit()
	local list_path = file_list()

	local buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(list_path))

	local win_id = vim.api.nvim_open_win(buf, true, {
		relative = "win",
		row = math.floor((vim.o.lines - 13) / 2),
		col = math.floor((vim.o.columns - (vim.o.columns * 0.6)) / 2),
		width = 75,
		height = 10,
	})

	vim.api.nvim_set_option_value("relativenumber", false, { win = win_id })

	local function Save()
		local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		vim.fn.writefile(content, list_path)
		vim.api.nvim_win_close(win_id, true)
		M.load()
	end

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = buf,
		callback = function()
			Save()
		end,
	})

	vim.keymap.set("n", "q", Save, { buffer = buf })
	vim.keymap.set("n", "<esc>", Save, { buffer = buf })
end

function M.setup(opts)
	opts = opts or {}
end

-- return
return M
