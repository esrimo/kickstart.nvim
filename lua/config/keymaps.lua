vim.keymap.set('n', '<leader>TD', '<cmd>TodoTelescope keywords=TODO<CR>')
vim.keymap.set('n', '<leader>TF', '<cmd>TodoTelescope keywords=FIX<CR>')

vim.keymap.set('n', '<leader>Ff', '<cmd>NvimTreeFindFile<CR>', { desc = 'NvimTreeFindFile' })

vim.keymap.set('n', '<leader>FF', function()
  local file = vim.fn.expand '%:p'
  local rel = vim.fn.fnamemodify(file, ':.')
  vim.fn.setreg('+', rel)
end, { desc = 'Copy File Path' })

vim.keymap.set('n', '<leader>md', '<cmd>RenderMarkdown toggle<CR>', { desc = 'Toggle Render Markdown' })

-- vim.keymap.set("n", "<C-s>", "<cmd>vsplit | tag <c-r><c-w><cr>", { silent = true })

-- folke / todo-comments plugin keymaps

vim.keymap.set('n', ']t', function()
  require('todo-comments').jump_next { keywords = { 'ERROR', 'WARN', 'TODO', 'HACK', 'NOTE' } }
end, { desc = 'Next comment: ERROR, WARNING, FIX, TODO, HACK, NOTE' })

vim.keymap.set('n', '[t', function()
  require('todo-comments').jump_prev { keywords = { 'ERROR', 'WARN', 'TODO', 'HACK', 'NOTE' } }
end, { desc = 'Previous todo comment' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Use arrow keys to resize the window splits instead of cursor navigation since this is what hjkl is for...
vim.keymap.set('n', '<left>', '<cmd>vertical resize -1<CR>')
vim.keymap.set('n', '<right>', '<cmd>vertical resize +1<CR>')
vim.keymap.set('n', '<up>', '<cmd>resize +1<CR>')
vim.keymap.set('n', '<down>', '<cmd>resize -1<CR>')

-- shows the error message from the LSP when there's a compile error or somehting
vim.keymap.set('n', '<leader>ds', vim.diagnostic.open_float, { desc = 'Show Diagnostic Bubble' })

-- will allow to FULLY QUIT NVIM instead of typing :wqa!
vim.keymap.set('n', '<leader>Q', '<cmd>confirm quitall<CR>', { desc = 'Quit without saving (:qa!)' })
vim.keymap.set('n', '<leader>W', '<cmd>confirm quitall<CR>', { desc = 'Save & Quit (:wqa!)' })

-- will just save whatever you're working instead of having to the :w which is turning into a paing in the assssss
vim.keymap.set('n', '<leader>S', '<cmd>:wall!<CR>', { desc = 'Save all buffers' })

-- will allow me to open an embedded terminal buffer with more ease
vim.keymap.set('n', '<leader>ot', '<cmd>:term<CR>', { desc = 'Open Terminal' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })
