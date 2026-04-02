local opt = vim.opt
local is_windows = vim.fn.has("win32") == 1
local is_mac     = vim.fn.has("mac") == 1

-- Компилятор для nvim-treesitter
if is_windows then
    -- Добавляем msys2/gcc и zig в PATH если они не видны nvim
    local msys_bin = "C:\\msys64\\ucrt64\\bin"
    if vim.fn.isdirectory(msys_bin) == 1 then
        vim.env.PATH = vim.env.PATH .. ";" .. msys_bin
    end
    vim.env.CC = "gcc"
end

-- Мышка
opt.mouse = "a"

-- Номера строк
opt.number         = true
opt.relativenumber = false

-- Отступы
opt.tabstop    = 4
opt.shiftwidth = 4
opt.expandtab  = true

-- Поиск
opt.ignorecase = true
opt.smartcase  = true

-- Внешний вид
opt.termguicolors = true
opt.signcolumn    = "yes"
opt.wrap          = false
opt.scrolloff     = 8

-- Буферы
opt.clipboard = "unnamedplus"