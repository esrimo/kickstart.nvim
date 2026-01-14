return {
  'mfussenegger/nvim-lint',
  optional = true,
  opts = function(_, opts)
    opts.linters_by_ft = { elixir = { 'credo', 'markdownlint-cli2' } }
    opts.linters = {
      credo = {
        condition = function(ctx)
          return vim.fs.find({ '.credo.exs' }, { path = ctx.filename, upward = true })[1]
        end,
      },
    }
  end,
}
