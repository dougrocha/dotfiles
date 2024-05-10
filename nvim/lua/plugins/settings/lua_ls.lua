-- https://luals.github.io/wiki/settings/
return {
  settings = {
    Lua = {
      telemetry = { enable = false },
      completion = {
        callSnippet = "Replace",
        workspaceWord = true,
      },
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
      },
    },
  },
}
