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

	vim.notify("Added: " .. vim.fn.fnamemodify(path, ":t"))
end

-- list args
function M.list()
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
	-- i dont know if i wnat this
	-- vim.cmd.args()
end

-- TODO: write
function M.load()
	local file = io.open(file_list(), "r")

	if not file then
		vim.notify("something wrong")
		return
	end

	for line in file:lines() do
		pcall(function()
			vim.cmd.arge(line)
			vim.cmd.argded()
		end)
	end
end

function M.edit()
	local list_path = file_list()
	local buf = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_name(buf, list_path)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(list_path))
	vim.api.nvim_open_win(buf, true, {
		relative = "win",
		row = math.floor((vim.o.lines - 13) / 2),
		col = math.floor((vim.o.columns - (vim.o.columns * 0.6)) / 2),
		width = 75,
		height = 10,
	})
end

function M.setup(opts)
	opts = opts or {}
	vim.keymap.set("n", "<leader>yu", M.list, {})
end

-- return
return M
