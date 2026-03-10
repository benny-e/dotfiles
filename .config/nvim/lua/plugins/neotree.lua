return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			filesystem = {
				follow_current_file = { enabled = true },
				hijack_netrw_behavior = "open_default",
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
				},
			},
			window = {
				position = "right",
				width = 32,
				mappings = {
					["<CR>"] = "open",
					["l"] = "open",
					["h"] = "close_node",
				},
			},
		},
		config = function(_, opts)
			require("neo-tree").setup(opts)

			vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Neo-tree: toggle" })
			vim.keymap.set("n", "<leader>E", "<cmd>Neotree focus<cr>", { desc = "Neo-tree: focus" })
		end,
	},
}
