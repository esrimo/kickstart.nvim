return {
  'athar-qadri/scratchpad.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-lua/plenary.nvim' }, -- don't forget to add this one if you don't have it yet!
  keys = {
    {
      '<Leader>note',
      function()
        local sp = require 'scratchpad'
        sp.ui:new_scratchpad()
      end,
      desc = 'open scratchpad notes',

      vim.keymap.set({ 'n', 'v' }, '<leader>pn', function()
        local sp = require 'scratchpad'
        sp.ui:sync()
      end, { desc = 'Push selection / current line to scratch pad' }),
    },
  },
  config = function()
    require('scratchpad'):setup {
      settings = {
        sync_on_ui_close = true,
        title = 'Esrimo scratch pad, i.e Notes',
      },
      default = {
        root_patterns = { '.git', 'package.json', 'README.md', 'pyproject.toml', 'build.gradle' },
      },
    }
  end,
}
