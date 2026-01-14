return {
  'mfussenegger/nvim-dap-python',
  dependencies = { 'mfussenegger/nvim-dap' },
  config = function()
    require('dap-python').setup '/Users/esrimo/repos/mhp/pfs-il-testing/src/container/.venv'
  end,
}
