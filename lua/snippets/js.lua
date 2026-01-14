local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

ls.add_snippets('javascript', {
  s('try', {
    t { 'try {', ' ' },
    i(1, '// code'),
    t { '', '} catch (e) {', ' ' },
    i(2, 'console.error({message: ` - ${e}`, trace: e})'),
    t { '', '}' },
  }),
})
