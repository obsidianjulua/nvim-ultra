-- lua/whichkey.lua

local wk = require("which-key")

wk.setup({
  plugins = {
    marks = true,
    registers = true,
    spelling = { enabled = true, suggestions = 20 },
    presets = {
      operators = true,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    },
  },
  icons = {
    breadcrumb = "»",
    separator = "➜",
    group = "+",
  },
  window = {
    border = "rounded",
    position = "bottom",
    margin = { 1, 0, 1, 0 },
    padding = { 1, 1, 1, 1 },
    winblend = 10  -- Slight transparency
  },
  layout = {
    height = { min = 4, max = 25 },
    width = { min = 20, max = 50 },
    spacing = 3,
    align = "left",
  },
})

-- Register our simple keybinding groups for easy discovery
wk.add({
  { "<leader>s", group = "Send to REPL" },
  { "<leader>r", desc = "Rename symbol" },
  { "<leader>a", desc = "Code actions" },
  { "<leader>e", desc = "File explorer" },
  { "gd", desc = "Go to definition" },
  { "K", desc = "Show documentation" },
})
