return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  lazy = false,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('nvim-tree').setup {
      view = {
        adaptive_size = true,
      },

      on_attach = function(bufnr)
        local api = require 'nvim-tree.api'

        local function opts(d)
          return {
            desc = 'nvim-tree: ' .. d,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
          }
        end

        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent, opts 'Up')
        vim.keymap.set('n', '?', api.tree.toggle_help, opts 'Help')
      end,
    }
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'NvimTreeToggle' })
  end,
}
