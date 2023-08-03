-- local status, telescope = pcall(require, "telescope")
-- if (not status) then return end

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>f", builtin.find_files, {})
vim.keymap.set("n", "<leader>g", builtin.live_grep, {})
-- vim.keymap.set("n", "<leader>b", builtin.buffers, {})
-- vim.keymap.set("n", "<leader>o", builtin.oldfiles, {})
vim.keymap.set("n", "<leader>h", builtin.help_tags, {})

local telescope = require("telescope")
telescope.setup({
	defaults = {
		winblend = 10,
	},
	pickers = {
		find_files = {
			hidden = true,
			initial_mode = "normal",
		},
		live_grep = {
			initial_mode = "normal",
		},
		buffers = {
			initial_mode = "normal",
		},
		oldfiles = {
			initial_mode = "normal",
		},
		help_tags = {
			initial_mode = "normal",
		},
	},
})

-- telescope file browser
require("telescope").load_extension("file_browser")

vim.keymap.set("n", "<leader>b", function()
	telescope.extensions.file_browser.file_browser({
		path = "%:p:h",
		-- cwd = telescope_buffer_dir(),
		respect_gitignore = false,
		hidden = true,
		grouped = true,
		-- previewer = false,
		initial_mode = "normal",
		-- layout_config = { height = 40 }
	})
end)

-- telescope media files
require("telescope").load_extension("media_files")
require("telescope").setup({
	extensions = {
		media_files = {
			-- filetypes whitelist
			-- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
			filetypes = { "png", "jpg", "jpeg", "mp4", "pdf" },
			find_cmd = "<leader>m", -- find command (defaults to `fd`)
		},
	},
})

-- telescope frecency
require("telescope").load_extension("frecency")
vim.api.nvim_set_keymap(
	"n",
	"<leader><leader>",
	"<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
	{ noremap = true, silent = true }
)
