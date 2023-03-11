-- import gitsigns plugin safely
local setup, diffview = pcall(require, "diffview")
if not setup then
  return
end

-- configure/enable gitsigns
diffview.setup()
