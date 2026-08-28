return {
  enabled = false,
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  'tiagovla/tokyodark.nvim',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  config = function(_, opts)
    ---@diagnostic disable-next-line: missing-fields
    require('tokyodark').setup(opts)
    vim.cmd.colorscheme 'tokyodark'
  end,
}

-- { -- You can easily change to a different colorscheme.
--   -- Change the name of the colorscheme plugin below, and then
--   -- change the command in the config to whatever the name of that colorscheme is.
--   --
--   -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
--   'folke/tokyonight.nvim',
--   priority = 1000, -- Make sure to load this before all the other start plugins.
--   config = function()
--     ---@diagnostic disable-next-line: missing-fields
--     require('tokyonight').setup {
--       styles = {
--         comments = { italic = false }, -- Disable italics in comments
--       },
--     }
--
--     -- Load the colorscheme here.
--     -- Like many other themes, this one has different styles, and you could load
--     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
--     -- vim.cmd.colorscheme 'tokyonight-night'
--   end,
-- },
-- {
--   {
--     'rebelot/kanagawa.nvim',
--     name = 'kanagawa',
--     priority = 1000,
--     config = function()
--       require('onedark').setup {
--         transparent = false,
--         dimInactive = true,
--         theme = 'wave',
--         background = {
--           dark = 'dragon', -- wave or lotus (light) is another option
--           light = 'dragon',
--         },
--       }
--       vim.cmd.colorscheme 'kanagawa-dragon'
--     end,
--   },
-- },
-- {
--   {
--     'navarasu/onedark.nvim',
--     name = 'onedark',
--     priority = 1000,
--     config = function()
--       require('onedark').setup {}
--       -- vim.cmd.colorscheme 'catppuccin-mocha'
--     end,
--   },
-- },
-- {
--   {
--     'catppuccin/nvim',
--     name = 'catppuccin',
--     priority = 1000,
--     config = function()
--       require('catppuccin').setup {
--         -- Your Catppuccin configuration options here
--       }
--       -- vim.cmd.colorscheme 'catppuccin-mocha'
--     end,
--   },
-- },
