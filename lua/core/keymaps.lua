local keymap = vim.keymap
vim.g.mapleader = " "

-- сохранить
keymap.set("n", "<leader>w", ":w<CR>",                    { desc = "💾 Сохранить файл" })
-- выйти
keymap.set("n", "<leader>q", ":q!<CR>",                    { desc = "❌ Выйти" })
-- открыть файловое дерево
keymap.set("n", "<leader>e", ":Neotree toggle<CR>",        { desc = "📁 Файловое дерево" })
-- сохранить и выйти
keymap.set("n", "<leader>s", ":wq<CR>",                   { desc = "💾❌ Сохранить и выйти" })
-- Поиск файла
keymap.set("n", "<leader>f", ":Telescope find_files<CR>",  { desc = "🔍 Найти файл" })
-- Поиск папки
keymap.set("n", "<leader>b", ":Telescope file_browser<CR>",{ desc = "📁 Открыть папку" })
-- Поиск текста
keymap.set("n", "<leader>g", ":Telescope live_grep<CR>",   { desc = "🔍 Найти текст" })