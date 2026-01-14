return {
  'pmizio/typescript-tools.nvim',
  ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'neovim/nvim-lspconfig',
  },
  opts = {
    on_attach = function(client, bufnr)
      -- disable built-in formatting if you use something else
      client.server_capabilities.documentFormattingProvider = false
      -- buffer-local keymaps:
      local m = { buffer = bufnr }
      vim.keymap.set('n', '<leader>co', ':TSToolsOrganizeImports<CR>', m)
      vim.keymap.set('n', '<leader>cr', ':TSToolsRenameFile<CR>', m)
      vim.keymap.set('n', '<leader>cf', ':TSToolsFixAll<CR>', m)
      vim.keymap.set('n', '<leader>ci', ':TSToolsAddMissingImports<CR>', m)
    end,
    settings = {
      -- spawn a second tsserver for diagnostics
      separate_diagnostic_server = true,
      -- when to ask for diagnostics: "change" or "insert_leave"
      publish_diagnostic_on = 'insert_leave',
      -- code-action exposure (can be "all" or list of actions)
      expose_as_code_action = {},
      -- any tsserver-file-preference overrides you like:
      tsserver_file_preferences = {
        includeInlayParameterNameHints = 'all',
        includeCompletionsForModuleExports = true,
      },
      -- plugin-specific memory, plugins, locale, etc. all live here:
      tsserver_max_memory = 'auto',
      tsserver_plugins = {},
      -- …and more (see below) …
    },
  },
}
