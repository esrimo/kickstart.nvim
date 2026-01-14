-- Highlight, edit, and navigate code
--
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs', -- Sets main module to use for opts
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  opts = {
    ensure_installed = {
      'yaml',
      'bash',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
      'java',
      'ninja',
      'rst',
      'python',
      'elixir',
      'heex',
      'eex',
      'css',
      'javascript',
      'typescript',
      'tsx',
    },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
    -- textobjects = {
    --   select = {
    --     enable = true,
    --     keymaps = {
    --       ['af'] = '@block.outer',
    --       ['if'] = '@block.inner',
    --     },
    --   },
    --   move = {
    --     enable = true,
    --     set_jumps = true,
    --     goto_next_start = {
    --       [']b'] = '@block.outer',
    --     },
    --     goto_previous_start = {
    --       ['[b'] = '@block.outer',
    --     },
    --   },
    -- },
  },
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
