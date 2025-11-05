# Tmux + Run = Train

- A lightweight Neovim plugin that runs your current file inside a tmux window, showing colorful output
  perfect for quick testing and compilation.

---

### Installation

- Lazy.vim

```lua
return {
	"hellopradeep69/Train",
	lazy = false, -- load immediately
	config = function()
		require("train").setup()
	end,
}
```

---

### Configuration | Optional

```lua
  require("train").setup({
      window_name = "Train", -- tmux window name
      cmd_map = {
        py = 'python3 "%file%"',
        java = 'javac "%file%" && java -cp "%dir%" "%basename%"',
        c = 'gcc "%file%" -o "%dir%/%basename%" && "%dir%/%basename%"',
        cpp = 'g++ "%file%" -o "%dir%/%basename%" && "%dir%/%basename%"',
        sh = 'bash "%file%"',
        lua = 'lua "%file%"',
        js = 'node "%file%"',
      },
    })
```

---

TODO: Plugin need a Re-write
