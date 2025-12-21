vim.api.nvim_create_user_command("Train", function()
	require("train").train() -- lowercase t matches lua/train/init.lua
end, {
	desc = "Run current file in tmux using Train plugin",
})
