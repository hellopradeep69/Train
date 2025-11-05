vim.api.nvim_create_user_command("Train", function()
	require("Train").train() -- assuming train is defined in lua/Train/init.lua
end, {
	desc = "Run current file in tmux using Train plugin",
})
