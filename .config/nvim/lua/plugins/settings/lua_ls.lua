-- https://luals.github.io/wiki/settings/
return {
  settings = {
    Lua = {
      telemetry = { enable = false },
      completion = {
        callSnippet = "Replace",
      },
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim", "spec" },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
          unpack(vim.api.nvim_get_runtime_file("", true)),
        },
      },
    },
  },
}
