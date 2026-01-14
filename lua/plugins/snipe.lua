return {
  'leath-dub/snipe.nvim',
  keys = {
    {
      'gm',
      function()
        require('snipe').open_buffer_menu()
      end,
      desc = 'Open Snipe buffer menu',
    },
  },
  opts = {
    sort = 'last',
    ui = {
      position = 'center',
      text_align = 'file-first',
    },
    hints = {
      dictionary = 'QWERT:LKJ',
    },
  },
}
