vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)
-- Set jump between splits to just crtl + l and ctrl + h
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
-- Fugitive keybind
vim.keymap.set("n", "<leader>g", ":Git<CR>", { desc = "Open Fugitive Git" })
