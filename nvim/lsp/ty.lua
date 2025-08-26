return {
    cmd = { "ty", "server" },
    filetypes = { "python" },
    root_markers = { "ty.toml", "pyproject.toml", ".git" },
    -- settings = {
    --     ty = {
    --         disableLanguageServices = true,
    --     },
    -- },
    init_options = {
        logLevel = "debug",
    },
}
