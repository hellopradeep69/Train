# Train.nvim - Navigation Fast as Train
----------
- what is Train
 - Harpoon using args

```
      oooOOOOOOOOOOO"
     o   ____          :::::::::::::::::: :::::::::::::::::: __|-----|__
     Y_,_|[]| --++++++ |[][][][][][][][]| |[][][][][][][][]| |  [] []  |
    {|_|_|__|;|______|;|________________|;|________________|;|_________|;
     /oo--OO   oo  oo   oo oo      oo oo   oo oo      oo oo   oo     oo
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
```

-----------
## Installation (using Lazy)

```lua
return {
    "hellopradeep69/Train"
	config = function()
		require("train").setup()
	end,
}
```

-----------
### Setup

```lua
map("n", "<leader>h", function()
	require("train").list()
end)

map("n", "<leader>H", function()
	require("train").add()
end)

map("n", "<C-h>", function()
	require("train").get(1)
end)

map("n", "<C-j>", function()
	require("train").get(2)
end)

map("n", "<C-k>", function()
	require("train").get(3)
end)

map("n", "<C-l>", function()
	require("train").get(4)
end)

map("n", "<leader>a", function()
	require("train").edit()
end)
```
----------
#### Other Train command

```lua
require("train").next
require("train").prev

```

