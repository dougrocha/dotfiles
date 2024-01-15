-- https://luals.github.io/wiki/settings/
return {
  settings = {
    Lua = {
      format = {
        enable = false,
      },
      telemetry = { enable = false },
      completion = {
        callSnippet = "Replace",
      },
      runtime = {
        version = "LuaJIT",
        special = {
          spec = "require",
        },
      },
      diagnostics = {
        globals = { "vim", "spec" },
        disable = { "missing-fields" },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
      },
    },
  },
}
