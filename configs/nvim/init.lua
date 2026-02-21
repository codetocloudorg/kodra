-- Kodra Neovim Configuration
-- A Code To Cloud Project ☁️
--
-- Minimal, sensible defaults for cloud developers

-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Appearance
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.scrolloff = 8

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Clipboard (system clipboard)
vim.opt.clipboard = 'unnamedplus'

-- Backup/swap
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undodir')

-- Update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- File encoding
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- Mouse support
vim.opt.mouse = 'a'

-- Key mappings
local keymap = vim.keymap.set

-- Clear search highlights
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Better window navigation
keymap('n', '<C-h>', '<C-w>h')
keymap('n', '<C-j>', '<C-w>j')
keymap('n', '<C-k>', '<C-w>k')
keymap('n', '<C-l>', '<C-w>l')

-- Resize windows
keymap('n', '<C-Up>', '<cmd>resize +2<CR>')
keymap('n', '<C-Down>', '<cmd>resize -2<CR>')
keymap('n', '<C-Left>', '<cmd>vertical resize -2<CR>')
keymap('n', '<C-Right>', '<cmd>vertical resize +2<CR>')

-- Move lines
keymap('v', 'J', ":m '>+1<CR>gv=gv")
keymap('v', 'K', ":m '<-2<CR>gv=gv")

-- Keep cursor centered
keymap('n', '<C-d>', '<C-d>zz')
keymap('n', '<C-u>', '<C-u>zz')
keymap('n', 'n', 'nzzzv')
keymap('n', 'N', 'Nzzzv')

-- Save file
keymap('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save file' })

-- Quit
keymap('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })

-- File explorer (netrw)
keymap('n', '<leader>e', '<cmd>Ex<CR>', { desc = 'File explorer' })

-- Buffer navigation
keymap('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
keymap('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Next buffer' })

-- Diagnostic keymaps
keymap('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
keymap('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
keymap('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostic' })

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    callback = function()
        local save_cursor = vim.fn.getpos('.')
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos('.', save_cursor)
    end,
})

-- Filetype settings for common Azure/cloud files
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'yaml', 'json', 'bicep', 'terraform' },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

-- Transparent background (works with terminal opacity)
vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = function()
        vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })
    end,
})

-- Apply transparency on startup
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'none' })

-- Kodra Theme Sync (#52)
-- Load colorscheme from kodra theme command if available
local kodra_theme_path = vim.fn.expand('~/.config/nvim/kodra-theme.lua')
if vim.fn.filereadable(kodra_theme_path) == 1 then
    local ok, kodra = pcall(dofile, kodra_theme_path)
    if ok and kodra and kodra.apply then
        vim.defer_fn(function()
            kodra.apply()
        end, 100)  -- Defer to allow plugins to load
    end
end

print('Kodra Neovim loaded! Press <Space> for leader commands.')
