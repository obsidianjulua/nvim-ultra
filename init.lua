-- init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
	'nvim-lua/plenary.nvim',
	'github/copilot.vim',
	'jpalardy/vim-slime',
	'neovim/nvim-lspconfig',
	'hrsh7th/nvim-cmp',
	'hrsh7th/cmp-nvim-lsp',
	'hrsh7th/cmp-buffer',
	'hrsh7th/cmp-path',
	'hrsh7th/cmp-cmdline',
	'saadparwaiz1/cmp_luasnip',
	'zbirenbaum/copilot-cmp',
	'nvim-tree/nvim-tree.lua',
	'nvim-treesitter/nvim-treesitter',
	'nvim-telescope/telescope.nvim',
	'folke/which-key.nvim',
	'nvim-tree/nvim-web-devicons',
	'echasnovski/mini.icons',
	'nvim-treesitter/nvim-treesitter-textobjects',
	'nvim-treesitter/nvim-treesitter-context',
	'nvim-treesitter/playground',
	'p00f/nvim-ts-rainbow',
	'windwp/nvim-autopairs',
	'lewis6991/gitsigns.nvim',
	'lukas-reineke/indent-blankline.nvim',
	'rcarriga/nvim-notify',
	'goolord/alpha-nvim',
	'petertriho/nvim-scrollbar',
	'karb94/neoscroll.nvim',
	'NvChad/nvim-colorizer.lua',
	'windwp/nvim-autopairs',
	'phaazon/hop.nvim',
	'folke/trouble.nvim',
}
require("plugins")
