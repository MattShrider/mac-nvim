-- import telescope plugin safely
local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
  return
end

-- import telescope actions safely
local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
  return
end

-- configure telescope
telescope.setup({
  -- configure custom mappings
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
        ["<C-j>"] = actions.move_selection_next, -- move to next result
        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
      },
    },
  },
  pickers = {
    buffers = {
      mappings = {
        n = {
          ["<C-x>"] = actions.delete_buffer,
        },
        i = {
          ["<C-x>"] = actions.delete_buffer,
        },
      },
    },
  },
  extensions = {
    undo = {
      -- requires https://github.com/dandavison/delta
      use_delta = true,
      side_by_side = true,
    },
  },
})

telescope.load_extension("fzf")
telescope.load_extension("undo")
