vim.wo.linebreak = true
vim.wo.spell = true
vim.bo.expandtab = true
vim.bo.shiftwidth = 2

vim.keymap.set({ "n", "x", "v" }, "j", "gj", { buffer = 0 })
vim.keymap.set({ "n", "x", "v" }, "k", "gk", { buffer = 0 })
vim.keymap.set("n", "<leader>P", "<CMD>MarkdownPreview<CR>",
    { buffer = 0, desc = "[P]review Markdown document" })
