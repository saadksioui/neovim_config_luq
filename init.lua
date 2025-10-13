-- ===============================
-- 🚀 Neovim IDE Setup for C & Web Development
-- ===============================

-- Set tab-related options
vim.opt.tabstop = 4       -- Number of spaces that a <Tab> counts for
vim.opt.softtabstop = 4   -- Number of spaces a <Tab> inserts while editing
vim.opt.shiftwidth = 4    -- Number of spaces to use for autoindent
vim.opt.expandtab = true  -- Convert tabs to spaces
vim.opt.smartindent = true -- Enable smart indentation

-- 🧩 Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ===============================
-- 📦 Plugins
-- ===============================
require("lazy").setup({

  -- LSP + Autocompletion
  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "L3MON4D3/LuaSnip",

  -- Mason (LSP/DAP installer)
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",

  -- 🌈 Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- 🧹 Conform for C formatter
 {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        c = { "c_formatter_42" },
        h = { "c_formatter_42" },
      },
      formatters = {
        c_formatter_42 = {
          command = "c_formatter_42",
          args = { "$FILENAME" },
          stdin = false, -- ✅ disable stdin (fixes the --stdin error)
        },
      },
      format_on_save = {
        lsp_fallback = true,
        timeout_ms = 2000,
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>f", function()
      require("conform").format({ async = true, lsp_fallback = true })
    end, { desc = "Format file" })
  end,
},

  -- 🌲 Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp", "lua", "python",
          "html", "css", "javascript", "typescript", "tsx", "json"
        },
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
      })
    end,
  },

  -- 🧭 Telescope (fuzzy finder)
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- 📁 File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end,
  },

  -- 💅 Formatting & Web Dev
  "jose-elias-alvarez/null-ls.nvim",
  "MunifTanjim/prettier.nvim",
  "windwp/nvim-ts-autotag",
  "windwp/nvim-autopairs",
  "NvChad/nvim-colorizer.lua",
})

-- ===============================
-- ⚙️ General Settings
-- ===============================
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.termguicolors = true
vim.g.mapleader = " "

-- ===============================
-- 🗝️ Keymaps
-- ===============================
-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")

-- NvimTree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>t", ":NvimTreeFocus<CR>", { desc = "Focus file tree" })

-- Telescope
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>")
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>")

-- ===============================
-- 🧩 Plugin Setup
-- ===============================
require("nvim-autopairs").setup()
require("nvim-ts-autotag").setup()
require("colorizer").setup()

-- ===============================
-- 🧠 Mason + LSP Setup
-- ===============================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "clangd", "ts_ls", "html", "cssls", "eslint", "tailwindcss" },
})

-- ===============================
-- 🧠 Autocompletion (nvim-cmp)
-- ===============================
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  }),
})

-- ===============================
-- 🧩 LSP Config (New API)
-- ===============================
local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Disable buggy color handler (fixes Neovim 0.10 LSP issue)
if vim.lsp.handlers["textDocument/documentColor"] then
  vim.lsp.handlers["textDocument/documentColor"] = function() end
end

-- LSP servers setup
local servers = {
  clangd = {},        -- C/C++
  ts_ls = {},         -- TypeScript/JavaScript
  html = {},          -- HTML
  cssls = {},         -- CSS
  eslint = {},        -- ESLint
  tailwindcss = {},   -- Tailwind
}

for name, config in pairs(servers) do
  local server = vim.lsp.config[name]
  if not server then
    vim.notify("LSP server not found: " .. name, vim.log.levels.WARN)
  else
    local opts = vim.tbl_deep_extend("force", {
      capabilities = capabilities,
      on_attach = on_attach,
    }, config)
    vim.lsp.start(vim.tbl_deep_extend("force", server, opts))
  end
end

-- ===============================
-- 💅 Prettier Setup
-- ===============================
require("prettier").setup({
  bin = "prettier",
  filetypes = {
    "javascript", "typescript", "css", "scss",
    "html", "json", "yaml", "markdown", "graphql"
  },
})
