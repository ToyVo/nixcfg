require("which-key").setup({
	plugins = {
		spelling = {
			enabled = true,
		},
	},
	window = {
		border = "rounded",
	},
})

-- Shift HL to change buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>")
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>")

-- Control hjkl to move between windows including terminal
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l")

-- Overwrite text in visual mode without overwriting the clipboard
vim.keymap.set("v", "p", '"_dP')

vim.keymap.set("n", "<leader>pf", "<cmd>Telescope find_files<cr>", { desc = "Project Files" })
vim.keymap.set("n", "<leader>ps", "<cmd>Telescope live_grep<cr>", { desc = "Project Search" })
vim.keymap.set("n", "<leader>vh", "<cmd>Telescope help_tags<cr>", { desc = "Help Tags" })
vim.keymap.set("n", "<C-p>", "<cmd>Telescope git_files<cr>", { desc = "Git Files" })
vim.keymap.set("n", "<leader>pi", "<cmd>TroubleToggle quickfix<cr>", { desc = "Project Issues" })
vim.keymap.set("n", "<leader>pv", vim.cmd.NvimTreeToggle, { desc = "Project View" })
vim.keymap.set("n", "<leader>u", vim.cmd.UndoTreeToggle, { desc = "UndoTree" })
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git" })

local mark = require("harpoon.mark")
local ui = require("harpoon.ui")
vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Add File to Harpoon" })
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, { desc = "Open Harpoon" })
vim.keymap.set("n", "<C-1>", function()
	ui.nav_file(1)
end, { desc = "Harpoon 1" })
vim.keymap.set("n", "<C-2>", function()
	ui.nav_file(2)
end, { desc = "Harpoon 2" })
vim.keymap.set("n", "<C-3>", function()
	ui.nav_file(3)
end, { desc = "Harpoon 3" })
vim.keymap.set("n", "<C-4>", function()
	ui.nav_file(4)
end, { desc = "Harpoon 4" })

-- Move highlighted text
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep centered
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Convenience
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "Q", "<nop>")

-- Diagnostics
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf })
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf })
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = ev.buf })
		vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, { buffer = ev.buf })
		vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { buffer = ev.buf })
		vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { buffer = ev.buf })
		vim.keymap.set("n", "<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, { buffer = ev.buf })
		vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { buffer = ev.buf })
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf })
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf })
		vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf })
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, { buffer = ev.buf })
		if vim.lsp.buf.range_code_action then
			vim.keymap.set("n", "<leader>ca", function()
				vim.lsp.buf.code_action()
			end, { buffer = ev.buf })
			vim.keymap.set("x", "<leader>ca", function()
				vim.lsp.buf.range_code_action()
			end, { buffer = ev.buf })
		else
			vim.keymap.set({ "n", "x" }, "<leader>ca", function()
				vim.lsp.buf.code_action()
			end, { buffer = ev.buf })
		end
	end,
})
