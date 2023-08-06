-- local status, telescope = pcall(require, "telescope")
-- if (not status) then return end

local builtin = require("telescope.builtin")
-- find系
vim.keymap.set("n", "<leader>f", builtin.find_files, {})
vim.keymap.set("n", "<leader>gg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>h", builtin.help_tags, {})
vim.keymap.set("n", "<leader>k", builtin.keymaps, {})
-- git系
vim.keymap.set("n", "<leader>gc", builtin.git_commits, {})
vim.keymap.set("n", "<leader>gb", builtin.git_branches, {})
vim.keymap.set("n", "<leader>gs", builtin.git_status, {})

-- other
local telescope = require("telescope")
telescope.setup({
	defaults = {
		winblend = 0,  -- 1にするだけで透過になる調整できないか？
		initial_mode = "normal",
	},
	pickers = {
		find_files = {
			hidden = true,
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
-- require("telescope").load_extension("media_files")
-- require("telescope").setup({
-- 	extensions = {
-- 		media_files = {
-- 			-- filetypes whitelist
-- 			-- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
-- 			filetypes = { "png", "jpg", "jpeg", "mp4", "pdf" },
-- 			find_cmd = "<leader>m", -- find command (defaults to `fd`)
-- 		},
-- 	},
-- })

-- telescope frecency
require("telescope").load_extension("frecency")
vim.api.nvim_set_keymap(
	"n",
	"<leader>r",
	"<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
	{ noremap = true, silent = true }
)
