-- auto install packer if not installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer() -- true if packer was just installed

-- autocommand that reloads neovim and installs/updates/removes plugins
-- when file is saved
vim.cmd([[ 
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
  augroup end
]])

-- import packer safely
local status, packer = pcall(require, "packer")
if not status then
  return
end

-- add list of plugins to install
return packer.startup(function(use)
  -- packer can manage itself
  use("wbthomason/packer.nvim")

  use("nvim-lua/plenary.nvim") -- lua functions that many plugins use

  use("bluz71/vim-nightfly-guicolors") -- preferred colorscheme

  use("christoomey/vim-tmux-navigator") -- tmux & split window navigation

  use("szw/vim-maximizer") -- maximizes and restores current window

  -- essential plugins
  use("tpope/vim-surround") -- add, delete, change surroundings (it's awesome)
  use("tpope/vim-sleuth") -- smart indent matching
  use("inkarkat/vim-ReplaceWithRegister") -- replace with register contents using motion (gr + motion)

  -- Shows keymaps interactively as you type
  use({
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end,
  })

  -- commenting with gc
  use("numToStr/Comment.nvim")

  -- file explorer
  use("nvim-tree/nvim-tree.lua")

  -- vs-code like icons
  use("nvim-tree/nvim-web-devicons")

  -- statusline
  use("nvim-lualine/lualine.nvim")

  -- fuzzy finding w/ telescope
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- dependency for better sorting performance
  -- Undo tree support in telescope
  use({ "debugloop/telescope-undo.nvim" })
  use({ "nvim-telescope/telescope.nvim", branch = "0.1.x" }) -- fuzzy finder

  -- autocompletion
  use("hrsh7th/nvim-cmp") -- completion plugin
  use("hrsh7th/cmp-buffer") -- source for text in buffer
  use("hrsh7th/cmp-path") -- source for file system paths

  -- snippets
  use("L3MON4D3/LuaSnip") -- snippet engine
  use("saadparwaiz1/cmp_luasnip") -- for autocompletion
  use("rafamadriz/friendly-snippets") -- useful snippets

  -- managing & installing lsp servers, linters & formatters
  use("williamboman/mason.nvim") -- in charge of managing lsp servers, linters & formatters
  use("williamboman/mason-lspconfig.nvim") -- bridges gap b/w mason & lspconfig

  -- configuring lsp servers
  use("neovim/nvim-lspconfig") -- easily configure language servers
  use("hrsh7th/cmp-nvim-lsp") -- for autocompletion
  use({
    "glepnir/lspsaga.nvim",
    branch = "main",
    requires = {
      { "nvim-tree/nvim-web-devicons" },
      { "nvim-treesitter/nvim-treesitter" },
    },
  }) -- enhanced lsp uis
  use("jose-elias-alvarez/typescript.nvim") -- additional functionality for typescript server (e.g. rename file & update imports)
  use("onsails/lspkind.nvim") -- vs-code like icons for autocompletion

  -- formatting & linting
  use("jose-elias-alvarez/null-ls.nvim") -- configure formatters & linters
  use("jayp0521/mason-null-ls.nvim") -- bridges gap b/w mason & null-ls

  -- treesitter configuration
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end,
  })

  -- indent guides and hidden chars
  use("lukas-reineke/indent-blankline.nvim")

  -- auto closing
  use("windwp/nvim-autopairs") -- autoclose parens, brackets, quotes, etc...
  use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" }) -- autoclose tags

  -- git integration
  use("lewis6991/gitsigns.nvim") -- show line modifications on left hand side
  use("tpope/vim-fugitive")
  use({
    "ruifm/gitlinker.nvim",
    requires = "nvim-lua/plenary.nvim",
  })
  use({ "sindrets/diffview.nvim", requires = "nvim-lua/plenary.nvim" })

  -- Find and replace
  use({ "windwp/nvim-spectre" })

  -- Markdown
  use({
    "iamcco/markdown-preview.nvim",
    run = function()
      vim.fn["mkdp#util#install"]()
    end,
  })

  -- Project folders and save sessions
  use({
    "gnikdroy/projections.nvim",
    config = function()
      require("projections").setup({
        workspaces = {
          -- Change this to wherever you clone your projects
          "~/dev",
        },

        -- Before saving a session, close out buffers that dirty the session file
        store_hooks = {
          pre = function()
            -- nvim-tree
            local nvim_tree_present, api = pcall(require, "nvim-tree.api")
            if nvim_tree_present then
              api.tree.close()
            end

            -- neo-tree
            if pcall(require, "neo-tree") then
              vim.cmd([[Neotree action=close]])
            end
          end,
        },
      })

      -- Bind <leader>fp to Telescope projections
      require("telescope").load_extension("projections")
      vim.keymap.set("n", "<leader>fp", function()
        vim.cmd("Telescope projections")
      end)

      -- Sessions are opt-in
      -- Autostore session on VimExit
      -- local Session = require("projections.session")
      -- vim.api.nvim_create_autocmd({ 'VimLeavePre' }, {
      --     callback = function() Session.store(vim.loop.cwd()) end,
      -- })
      --
      -- -- Switch to project if vim was started in a project dir
      -- local switcher = require("projections.switcher")
      -- vim.api.nvim_create_autocmd({ "VimEnter" }, {
      --     callback = function()
      --         if vim.fn.argc() == 0 then switcher.switch(vim.loop.cwd()) end
      --     end,
      -- })

      -- Adds user commands for manually storing and restoring sessions
      local Session = require("projections.session")
      vim.api.nvim_create_user_command("StoreProjectSession", function()
        Session.store(vim.loop.cwd())
      end, {})

      vim.api.nvim_create_user_command("RestoreProjectSession", function()
        Session.restore(vim.loop.cwd())
      end, {})
    end,
  })

  --debugging
  use("mfussenegger/nvim-dap")
  use("nvim-telescope/telescope-dap.nvim")
  use({ "theHamsta/nvim-dap-virtual-text", requires = { "mfussenegger/nvim-dap" } })
  use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })
  -- requires delve
  use("leoluz/nvim-dap-go")

  if packer_bootstrap then
    require("packer").sync()
  end
end)
