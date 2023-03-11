local setup, daptext = pcall(require, "nvim-dap-virtual-text")
if not setup then
  return
end

daptext.setup()
