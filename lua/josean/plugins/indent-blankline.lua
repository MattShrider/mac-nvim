-- import gitsigns plugin safely
local setup, indentline = pcall(require, "indent_blankline")
if not setup then
  return
end

-- configure/enable gitsigns
indentline.setup({
  show_current_context = true,
  show_current_context_start = true,
  space_char_blankline = " ",
})
