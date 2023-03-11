-- import lualine plugin safely
local status, jester = pcall(require, "jester")
if not status then
  return
end

jester.setup({})
