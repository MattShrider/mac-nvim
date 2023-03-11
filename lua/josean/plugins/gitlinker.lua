-- import gitsigns plugin safely
local setup, gitlinker = pcall(require, "gitlinker")
if not setup then
  return
end

-- configure/enable gitsigns
gitlinker.setup()
