vim.wo.linebreak = true
vim.wo.spell = true

vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})

vim.keymap.set({ "n", "x", "v" }, "j", "gj", { buffer = 0 })
vim.keymap.set({ "n", "x", "v" }, "k", "gk", { buffer = 0 })
vim.keymap.set("n", "<leader>P", "<CMD>PeekOpen<CR>", { buffer = 0, desc = "[P]review Markdown document" })
