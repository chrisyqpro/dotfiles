-- Option
vim.g.have_nerd_font = true
vim.g.markdown_recommended_style = 0 -- Fix markdown indentation settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.colorcolumn = "80,120"
vim.o.cursorline = true
vim.o.tabstop = 8
vim.o.softtabstop = -1
vim.o.shiftwidth = 4
vim.o.breakindent = true
vim.o.list = true
vim.o.listchars = "tab:>-,trail:•,nbsp:␣"
vim.o.conceallevel = 2 -- Hide * markup, but not markers with substitutions in md
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.showmatch = true
vim.o.scrolloff = 10
vim.o.smoothscroll = true
vim.o.showmode = false
vim.o.laststatus = 3
vim.o.winborder = "rounded"
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = "split"
vim.o.ignorecase = true -- Case-insensitive searching UNLESS \C or input capitals
vim.o.smartcase = true
vim.o.undofile = true
vim.o.completeopt = "fuzzy,menu,menuone,noinsert,preview"

-- Autocmd
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Base keymap
local map = vim.keymap.set
vim.g.mapleader = " "
vim.g.maplocalleader = " "
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("v", "J", ":m '>+1<CR>gv=gv") -- Move line down
map("v", "K", ":m '<-2<CR>gv=gv") -- Move line up
map("n", "J", "mzJ`z") -- Keep cursor in the same place after J
map("n", "<C-d>", "<C-d>zz") -- Center cursorline after page-down
map("n", "<C-u>", "<C-u>zz") -- Center cursorline after page-up
map("n", "n", "nzzzv") -- Center cursorline and open enough folds on search result
map("n", "N", "Nzzzv") -- Center cursorline and open enough folds on search result
map("n", "=ap", "ma=ap'a") -- Return cursor to 0 when indent a paragraph
map({ "n", "v" }, "<leader>y", [["+y]]) -- Yank into system clipboard
map("n", "<leader>Y", [["+Y]])
map({ "n", "v" }, "<leader>x", [["+d]]) -- Kill into system clipboard
map("n", "<leader>X", [["+X]])
map("x", "<leader>p", [["_dP]]) -- Paste w/o overwrite default register
map({ "n", "v" }, "<leader>d", [["_d]]) -- Kill w/o overwrite default register
map("n", "<leader>E", vim.cmd.Ex) -- Open netrw file manager
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Plugins
vim.pack.add({
    "https://github.com/vague2k/vague.nvim",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/echasnovski/mini.nvim",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    "https://github.com/nvim-treesitter/nvim-treesitter-context",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
    "https://github.com/windwp/nvim-autopairs",
    "https://github.com/windwp/nvim-ts-autotag",
    "https://github.com/j-hui/fidget.nvim",
    { src = "https://github.com/L3MON4D3/LuaSnip", version = vim.version.range("2.*") },
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
    "https://github.com/stevearc/conform.nvim",
    "https://github.com/mfussenegger/nvim-lint",
    "https://github.com/rcarriga/nvim-dap-ui",
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/mfussenegger/nvim-dap",
    "https://codeberg.org/mfussenegger/nvim-dap-python",
    "https://github.com/toppair/peek.nvim",
    { src = "https://github.com/chomosuke/typst-preview.nvim", verion = vim.version.range("1.*") },
    "https://github.com/Vigemus/iron.nvim",
})

-- Theme
require("vague").setup({ transparent = true })
vim.cmd.colorscheme("vague")

-- Git
map("n", "<leader>gf", ":diffget 1<CR>", { desc = "Get diff buffer 1 [L]" })
map("n", "<leader>gj", ":diffget 3<CR>", { desc = "Get diff buffer 3 [R]" })
-- Gitsigns
require("gitsigns").setup({
    signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
    },
    signs_staged = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]h", function()
            if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
            else
                gitsigns.nav_hunk("next")
            end
        end, { desc = "Jump to next git [c]hange (hunk) " })

        map("n", "[h", function()
            if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
            else
                gitsigns.nav_hunk("prev")
            end
        end, { desc = "Jump to prev git [c]hange (hunk)" })

        -- Actions
        map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
        map("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "git preview hunk [i]nline" })
        map("n", "<leader>hb", function()
            gitsigns.blame_line({ full = true })
        end, { desc = "git [b]lame line" })
        map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index" })
        map("n", "<leader>hD", function()
            gitsigns.diffthis("@")
        end, { desc = "git [D]iff against last commit" })
        -- Toggles
        map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[T]oggle git show [b]lame line" })
        -- Text object
        map({ "o", "x" }, "ih", gitsigns.select_hunk)
    end,
})

-- Utilities from mini
require("mini.ai").setup({ n_lines = 500 }) -- Around/Inside textobjects
require("mini.surround").setup() -- Surrounding Add/Delete/Replace
require("mini.icons").setup()
local statusline = require("mini.statusline")
statusline.setup({ use_icons = vim.g.have_nerd_font })
statusline.section_location = function()
    return "%2l:%-2v"
end
require("mini.pick").setup({
    mappings = {
        send_marked_to_quickfix = {
            char = "<C-q>",
            func = function()
                local items = MiniPick.get_picker_matches().marked
                MiniPick.default_choose_marked(items)
                return true
            end,
        },
        send_marked_to_location_list = {
            char = "<C-l>",
            func = function()
                local items = MiniPick.get_picker_matches().marked
                MiniPick.default_choose_marked(items, { list_type = "location" })
                return true
            end,
        },
    },
})
require("mini.extra").setup()
-- Keymap for pickers
-- TODO: simplify by using builtin list as much as possible
map("n", "<leader>sf", MiniPick.builtin.files, { desc = "[S]earch [F]iles" })
map("n", "<leader>ss", MiniExtra.pickers.git_files, { desc = "[S]earch [S]ource(Git) Files" })
map("n", "<leader>sw", function()
    local word = vim.fn.expand("<cword>")
    MiniPick.builtin.grep({ pattern = word })
end)
map("n", "<leader>sW", function()
    local word = vim.fn.expand("<cWORD>")
    MiniPick.builtin.grep({ pattern = word })
end, { desc = "[S]earch c[W]ORD" })
map("n", "<leader>sg", MiniPick.builtin.grep, { desc = "[S]earch [G]rep" })
local get_selection = function()
    return vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { mode = vim.fn.mode() })
end
map("v", "<leader>sg", function()
    local select = get_selection()
    MiniPick.builtin.grep({ pattern = table.concat(select) })
end, { desc = "[S]earch [G]rep Visual" })
map("n", "<leader>sG", MiniPick.builtin.grep_live, { desc = "[S]earch [G]rep Live" })
map("n", "<leader>/", function()
    MiniExtra.pickers.buf_lines({ scope = "current" })
end, { desc = "[/] Search in current buffer" })
map("n", "<leader><leader>", MiniPick.builtin.buffers, { desc = "[ ] Find existing buffers" })
map("n", "<leader>s.", MiniExtra.pickers.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
map("n", "<leader>sr", MiniPick.builtin.resume, { desc = "[R]esume [S]earch" })
map("n", "<leader>sh", MiniPick.builtin.help, { desc = "[S]earch [H]elp" })
map("n", "<leader>sk", MiniExtra.pickers.keymaps, { desc = "[S]earch [K]eymaps" })
map("n", "<leader>sd", MiniExtra.pickers.diagnostic, { desc = "[S]earch [D]iagnostics" })
-- Highlight comment tag and hex color
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
    highlighters = {
        fixme = { pattern = { "%f[%w]()FIXME()%f[%W]" }, group = "MiniHipatternsFixme" },
        hack = { pattern = { "%f[%w]()HACK()%f[%W]", "%f[%w]()WARN()%f[%W]" }, group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note = { pattern = { "%f[%w]()NOTE()%f[%W]", "%f[%w]()INFO()%f[%W]" }, group = "MiniHipatternsNote" },
        hex_color = hipatterns.gen_highlighter.hex_color(),
    },
})

-- Oil file
local oil_detail = false
require("oil").setup({
    default_file_explorer = false,
    delete_to_trash = true,
    view_options = {
        show_hidden = true,
    },
    keymaps = {
        ["gd"] = {
            desc = "Toggle file detail view",
            callback = function()
                oil_detail = not oil_detail
                if oil_detail then
                    require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
                else
                    require("oil").set_columns({ "icon" })
                end
            end,
        },
    },
})
map("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
package.loaded["oil.adapters.trash"] = require("oil.adapters.trash.freedesktop")

-- Autopair
require("nvim-autopairs").setup()
require("nvim-ts-autotag").setup()

-- Treesitter
-- stylua: ignore start
local treesitters = {
    "angular", "asm", "bash", "sh", "beancount", "bibtex", "c", "c_sharp", "cmake", "commonlisp", "cpp", "css", "csv",
    "cuda", "dart", "diff", "disassembly", "dockerfile", "editorconfig", "git_config", "git_rebase", "gitattributes",
    "gitcommit", "gitignore", "glsl", "go", "graphql", "hlsl", "html", "http", "java", "javascript", "jsdoc", "json",
    "json5", "jsonc", "kotlin", "latex", "llvm", "lua", "luadoc", "luap", "make", "markdown", "markdown_inline", "matlab",
    "objc", "odin", "php", "printf", "python", "query", "regex", "ruby", "rust", "scala", "sql", "swift", "terraform",
    "toml", "tsx", "typescript", "typst", "vala", "vim", "vimdoc", "vue", "xml", "yaml", "zig",
}
-- stylua: ignore end
require("nvim-treesitter").install(treesitters)
vim.api.nvim_create_autocmd("FileType", {
    pattern = treesitters,
    callback = function()
        vim.treesitter.start()
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})
-- Show current context with treesitter
require("treesitter-context").setup({
    enable = true,
    multiwindow = false,
    max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
    min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    line_numbers = true,
    multiline_threshold = 20, -- Maximum number of lines to show for a single context
    trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
    separator = nil,
    zindex = 20, -- The Z-index of the context window
    on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
})
require("nvim-treesitter-textobjects").setup({
    select = {
        lookahead = true,
        selection_modes = {
            ["@parameter.outer"] = "v", -- charwise
            ["@function.outer"] = "V", -- linewise
            ["@class.outer"] = "<c-v>", -- blockwise
        },
    },
    move = {
        set_jumps = true,
    },
})
local ts_move = require("nvim-treesitter-textobjects.move")
local ts_select = require("nvim-treesitter-textobjects.select")
local ts_swap = require("nvim-treesitter-textobjects.swap")
map({ "x", "o" }, "aF", function()
    ts_select.select_textobject("@function.outer", "textobjects")
end)
map({ "x", "o" }, "iF", function()
    ts_select.select_textobject("@function.inner", "textobjects")
end)
map({ "x", "o" }, "ac", function()
    ts_select.select_textobject("@class.outer", "textobjects")
end)
map({ "x", "o" }, "ic", function()
    ts_select.select_textobject("@class.inner", "textobjects")
end)
map({ "x", "o" }, "as", function()
    ts_select.select_textobject("@local.scope", "locals")
end)
map("n", "<leader>a", function()
    ts_swap.swap_next("@parameter.inner")
end)
map("n", "<leader>A", function()
    ts_swap.swap_previous("@parameter.outer")
end)
map({ "n", "x", "o" }, "]m", function()
    ts_move.goto_next_start("@function.outer", "textobjects")
end)
map({ "n", "x", "o" }, "]]", function()
    ts_move.goto_next_start("@class.outer", "textobjects")
end)
map({ "n", "x", "o" }, "]o", function()
    ts_move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
end)
map({ "n", "x", "o" }, "]s", function()
    ts_move.goto_next_start("@local.scope", "locals")
end)
map({ "n", "x", "o" }, "]z", function()
    ts_move.goto_next_start("@fold", "folds")
end)
map({ "n", "x", "o" }, "]a", function()
    ts_move.goto_next_start("@parameter.inner", "textobjects")
end)
map({ "n", "x", "o" }, "]c", function()
    ts_move.goto_next_start("@comment.outer", "textobjects")
end)

map({ "n", "x", "o" }, "]M", function()
    ts_move.goto_next_end("@function.outer", "textobjects")
end)
map({ "n", "x", "o" }, "][", function()
    ts_move.goto_next_end("@class.outer", "textobjects")
end)

map({ "n", "x", "o" }, "[m", function()
    ts_move.goto_previous_start("@function.outer", "textobjects")
end)
map({ "n", "x", "o" }, "[[", function()
    ts_move.goto_previous_start("@class.outer", "textobjects")
end)
map({ "n", "x", "o" }, "[o", function()
    ts_move.goto_previous_start({ "@loop.inner", "@loop.outer" }, "textobjects")
end)
map({ "n", "x", "o" }, "[s", function()
    ts_move.goto_previous_start("@local.scope", "locals")
end)
map({ "n", "x", "o" }, "[z", function()
    ts_move.goto_previous_start("@fold", "folds")
end)
map({ "n", "x", "o" }, "[a", function()
    ts_move.goto_previous_start("@parameter.inner", "textobjects")
end)
map({ "n", "x", "o" }, "[c", function()
    ts_move.goto_previous_start("@comment.outer", "textobjects")
end)

map({ "n", "x", "o" }, "[M", function()
    ts_move.goto_previous_end("@function.outer", "textobjects")
end)
map({ "n", "x", "o" }, "[]", function()
    ts_move.goto_previous_end("@class.outer", "textobjects")
end)
local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
map({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move, { expr = true })
map({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite, { expr = true })
map({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
map({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
map({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
map({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

-- Snippet
local ls = require("luasnip")
ls.setup({ enable_autosnippets = true })
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
map("i", "<C-E>", function()
    ls.expand_or_jump(1)
end, { silent = true, desc = "[E]xpand snippet" })
map({ "i", "s" }, "<C-;>", function()
    ls.jump(1)
end, { silent = true, desc = "Jump forward" })
map({ "i", "s" }, "<C-,>", function()
    ls.jump(-1)
end, { silent = true, desc = "Jump backward" })

-- LSP
require("fidget").setup()
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("neovim-lsp-attach", { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end
        -- map("grd", vim.lsp.buf.definition, "[G]oto [D]efinition")
        map("gd", function()
            MiniExtra.pickers.lsp({ scope = "definition" })
        end, "[G]oto [D]efinition")
        map("gr", function()
            MiniExtra.pickers.lsp({ scope = "references" })
        end, "[G]oto [R]eferences") -- built-in: grr
        map("gI", function()
            MiniExtra.pickers.lsp({ scope = "implementation" })
        end, "[G]oto [I]mplementation") -- built-in: gri
        map("<leader>D", function()
            MiniExtra.pickers.lsp({ scope = "type_definition" })
        end, "Type [D]efinition") -- built-in: grt
        map("<leader>ds", function()
            MiniExtra.pickers.lsp({ scope = "document_symbol" })
        end, "[D]ocument [S]ymbols") -- built-in: gO
        map("<leader>ws", function()
            MiniExtra.pickers.lsp({ scope = "workspace_symbol" })
        end, "[W]orkspace [S]ymbols")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame") -- grn
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" }) --gra
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
        map("<leader>cc", vim.lsp.codelens.run, "Run [C]odelens", { "n", "v" })
        map("<leader>cC", vim.lsp.codelens.refresh, "Refresh & Dislay [C]odelens", { "n", "v" })
        map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
        end, "[T]oggle Inlay [H]ints")

        -- local client = vim.lsp.get_client_by_id(event.data.client_id)
        -- if client and client.name == "tsgo" then
        --     client.server_capabilities.completionProvider = nil
        -- end
    end,
})
vim.diagnostic.config({
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = vim.g.have_nerd_font and {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
    } or {},
    virtual_text = {
        source = "if_many",
        spacing = 4,
        format = function(diagnostic)
            local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
        end,
    },
})
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.lsp.enable({ "lua_ls", "tinymist", "ruff", "ty", "pyright", "bashls", "ts_ls", "tsgo" })

-- Autocomplete
local auto_blink = false
if vim.env.AUTO_BLINK == "1" then
    auto_blink = true
end
require("blink.cmp").setup({
    keymap = {
        preset = "default",
    },
    completion = {
        menu = { auto_show = auto_blink },
        documentation = { auto_show = auto_blink, auto_show_delay_ms = 500 },
    },
    snippets = { preset = "luasnip" },
    fuzzy = { implementation = "prefer_rust_with_warning" },
    signature = { enabled = auto_blink },
})

-- Autoformat
require("conform").setup({
    notify_on_error = false,
    format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
            lsp_format_opt = "never"
        else
            lsp_format_opt = "fallback"
        end
        return {
            timeout_ms = 500,
            lsp_format = lsp_format_opt,
        }
    end,
    formatters_by_ft = {
        lua = { "stylua" },
        python = {
            -- To fix auto-fixable lint errors.
            "ruff_fix",
            -- To run the Ruff formatter.
            "ruff_format",
            -- To organize the imports.
            "ruff_organize_imports",
        },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
    },
})
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
map("n", "<leader>f", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })

-- Linting
local lint = require("lint")
lint.linters_by_ft = {
    markdown = { "markdownlint-cli2" },
    javascript = { "eslint" },
    typescript = { "eslint" },
}
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function()
        if vim.opt_local.modifiable:get() then
            lint.try_lint()
        end
    end,
})

-- Debugger
local dap = require("dap")
local dapui = require("dapui")
dap.set_log_level("DEBUG")
dapui.setup({
    icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
    controls = {
        icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
        },
    },
})
-- Change breakpoint icons
vim.api.nvim_set_hl(0, "DapBreak", { fg = "#d8647e" }) -- error
vim.api.nvim_set_hl(0, "DapStop", { fg = "#f3be7c" }) -- warning
local breakpoint_icons = vim.g.have_nerd_font
        and {
            Breakpoint = "",
            BreakpointCondition = "",
            BreakpointRejected = "",
            LogPoint = "",
            Stopped = "",
        }
    or {
        Breakpoint = "●",
        BreakpointCondition = "⊜",
        BreakpointRejected = "⊘",
        LogPoint = "◆",
        Stopped = "⭔",
    }
for type, icon in pairs(breakpoint_icons) do
    local tp = "Dap" .. type
    local hl = (type == "Stopped") and "DapStop" or "DapBreak"
    vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
end

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

-- Keymap
map("n", "<F5>", function()
    require("dap").continue()
end, { desc = "Debug: Start/Continue" })
map("n", "<F1>", function()
    require("dap").step_into()
end, { desc = "Debug: Step Into" })
map("n", "<F2>", function()
    require("dap").step_over()
end, { desc = "Debug: Step Over" })
map("n", "<F3>", function()
    require("dap").step_out()
end, { desc = "Debug: Step Out" })
map("n", "<leader>b", function()
    require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })
map("n", "<leader>B", function()
    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Set Breakpoint" })
-- -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
map("n", "<F7>", function()
    require("dapui").toggle()
end, { desc = "Debug: See last session result." })

-- Install golang specific config
-- require('dap-go').setup {
--   delve = {
--     -- On Windows delve must be run attached or it crashes.
--     -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
--     detached = vim.fn.has 'win32' == 0,
--   },
-- }

-- Doc preview
-- Markdown
require("peek").setup({
    filetype = { "markdown", "conf" },
})
-- Typst
require("typst-preview").setup({ dependencies_bin = {
    ["tinymist"] = "tinymist",
    ["websocat"] = "websocat",
} })

-- Repl
local common = require("iron.fts.common")
local iron = require("iron.core")
local view = require("iron.view")

iron.setup({
    config = {
        scratch_repl = true,
        repl_definition = {
            python = {
                command = { "python" },
                format = common.bracketed_paste_python,
            },
        },
        repl_open_cmd = view.right(60),
    },
    keymaps = {
        send_motion = "<leader>Rc",
        visual_send = "<leader>Rc",
        send_file = "<leader>Rf",
        send_line = "<leader>Rl",
        send_mark = "<leader>Rm",
        mark_motion = "<leader>Rmc",
        mark_visual = "<leader>Rmc",
        remove_mark = "<leader>Rmd",
        cr = "<leader>R<cr>",
        interrupt = "<leader>R<leader>",
        exit = "<leader>Rq",
        clear = "<leader>Rx",
    },
    highlight = {
        italic = true,
    },
    ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
})
map("n", "<leader>Rs", "<cmd>IronRepl<cr>")
map("n", "<leader>Rr", "<cmd>IronRestart<cr>")
map("n", "<leader>RF", "<cmd>IronFocus<cr>")
map("n", "<leader>Rh", "<cmd>IronHide<cr>")

-- Jupyter Notebook
-- TODO: github.com/benlubas/molten-nvim
