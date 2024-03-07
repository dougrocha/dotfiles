return {
  on_attach = function(client)
    client.server_capabilities.signatureHelpProvider = false
  end,
}
