local is_windows = vim.fn.has("win32") == 1
local is_mac     = vim.fn.has("mac") == 1

-- Определяем shell для терминала
local shell
if is_windows then
    shell = "powershell.exe"
elseif is_mac then
    shell = "/bin/zsh"
else
    shell = "/bin/bash"
end

return {
    -- ─────────────────────────────────────────────
    -- Стартовый экран (Alpha)
    -- ─────────────────────────────────────────────
    {
        "goolord/alpha-nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            local alpha     = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                "╔════════════════════════╗",
                "║  Safe ass NeoVim       ║",
                "╚════════════════════════╝",
            }

            dashboard.section.buttons.val = {
                dashboard.button("f", "📄 Открыть файл",  ":Telescope find_files<CR>"),
                dashboard.button("n", "🆕 Создать файл",  ":ene <BAR> startinsert<CR>"),
                dashboard.button("b", "📁 Открыть папку", ":Telescope file_browser<CR>"),
                dashboard.button("r", "🔍 Найти текст",   ":Telescope live_grep<CR>"),
                dashboard.button("q", "❌ Выйти",         ":qa<CR>"),
            }

            dashboard.section.footer.val = "Добро пожаловать!"
            alpha.setup(dashboard.opts)
        end,
    },

    -- ─────────────────────────────────────────────
    -- Файловый менеджер (Neo-tree)
    -- ─────────────────────────────────────────────
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function()
                    local root = vim.fs.root(0, {
                        ".git",
                        "package.json",
                        "pyproject.toml",
                        "Cargo.toml",
                    })
                    if root then
                        vim.cmd("cd " .. root)
                    end
                end,
            })

            require("neo-tree").setup({
                filesystem = {
                    follow_current_file    = { enabled = true },
                    use_libuv_file_watcher = true,
                    filtered_items         = { hide_dotfiles = false },
                },
                window = {
                    mappings = {
                        -- Открыть файл (переходит в существующий буфер или создаёт новый)
                        ["<cr>"] = "open",
                        -- Создание файла
                        ["a"] = {
                            "add",
                            config = { show_path = "relative" },
                        },
                        -- Создание папки
                        ["A"] = {
                            "add_directory",
                            config = { show_path = "relative" },
                        },
                        -- Удалить
                        ["d"] = "delete",
                        -- Переименовать
                        ["r"] = "rename",
                        -- Копировать
                        ["c"] = "copy",
                        -- Переместить
                        ["m"] = "move",
                    },
                },
            })
        end,
    },

    -- ─────────────────────────────────────────────
    -- Подсветка синтаксиса (Treesitter)
    -- ─────────────────────────────────────────────
    {
        "nvim-treesitter/nvim-treesitter",
        commit = "v0.9.3",
        build  = ":TSUpdate",
        lazy   = false,
        config = function()
            local install = require("nvim-treesitter.install")

            if is_windows then
                install.compilers = { "gcc", "zig" }
            elseif is_mac then
                install.compilers = { "clang", "gcc" }
            else
                install.compilers = { "gcc", "clang" }
            end

            install.prefer_git = true

            -- Определяем какой модуль доступен в этой версии
            local ok_new, ts_new = pcall(require, "nvim-treesitter.config")
            local ok_old, ts_old = pcall(require, "nvim-treesitter.configs")

            local ts_setup
            if ok_new then
                ts_setup = ts_new
            elseif ok_old then
                ts_setup = ts_old
            else
                vim.notify("nvim-treesitter: модуль не найден", vim.log.levels.ERROR)
                return
            end

            ts_setup.setup({
                ensure_installed = {
                    "lua", "python", "javascript",
                    "typescript", "html", "css",
                    "json", "yaml", "bash", "markdown",
                    "c", "cpp",
                },
                auto_install = true,
                highlight = {
                    enable                            = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        lazy = false,
    },

    -- ─────────────────────────────────────────────
    -- LSP
    -- ─────────────────────────────────────────────
    {
        "neovim/nvim-lspconfig",
    },

    -- ─────────────────────────────────────────────
    -- Mason — установка языковых серверов
    -- ─────────────────────────────────────────────
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },

    -- ─────────────────────────────────────────────
    -- Тема (Catppuccin)
    -- ─────────────────────────────────────────────
    {
        "catppuccin/nvim",
        name     = "catppuccin",
        priority = 1000,
        config   = function()
            require("catppuccin").setup({
                flavour         = "mocha",
                semantic_tokens = true,
                treesitter      = true,
                integrations = {
                    neo_tree           = true,
                    telescope          = true,
                    mason              = true,
                    which_key          = true,
                    cmp                = true,
                    treesitter_context = true,
                },
                color_overrides = {
                    mocha = {
                        red    = "#FF5555",
                        green  = "#50FA7B",
                        yellow = "#F1FA8C",
                        blue   = "#8BE9FD",
                        pink   = "#FF79C6",
                        mauve  = "#BD93F9",
                    },
                },
                highlight_overrides = {
                    mocha = function(c)
                        return {
                            ["@function"]           = { fg = c.pink,     style = { "bold" } },
                            ["@function.builtin"]   = { fg = c.pink,     style = { "bold" } },
                            ["@keyword"]            = { fg = c.mauve,    style = { "bold" } },
                            ["@keyword.return"]     = { fg = c.mauve,    style = { "bold" } },
                            ["@string"]             = { fg = c.green },
                            ["@number"]             = { fg = c.peach },
                            ["@comment"]            = { fg = c.overlay1, style = { "italic" } },
                            ["@type"]               = { fg = c.yellow,   style = { "bold" } },
                            ["@variable"]           = { fg = c.text },
                            ["@variable.parameter"] = { fg = c.blue },
                        }
                    end,
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    -- ─────────────────────────────────────────────
    -- Mason-lspconfig
    -- ─────────────────────────────────────────────
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "pyright", "lua_ls", "clangd" },
                handlers = {
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            capabilities = require("cmp_nvim_lsp").default_capabilities(),
                            on_attach = function(client, bufnr)
                                if client.server_capabilities.semanticTokensProvider then
                                    vim.lsp.semantic_tokens.start(bufnr, client.id)
                                end
                            end,
                        })
                    end,

                    ["clangd"] = function()
                        require("lspconfig").clangd.setup({
                            capabilities = require("cmp_nvim_lsp").default_capabilities(),
                            on_attach = function(client, bufnr)
                                if client.server_capabilities.semanticTokensProvider then
                                    vim.lsp.semantic_tokens.start(bufnr, client.id)
                                end
                            end,
                            cmd       = { "clangd", "--background-index", "--clang-tidy" },
                            filetypes = { "c", "cpp", "h", "hpp" },
                        })
                    end,
                },
            })
        end,
    },

    -- ─────────────────────────────────────────────
    -- Автодополнение (nvim-cmp)
    -- ─────────────────────────────────────────────
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ["<Tab>"]   = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                    ["<CR>"]    = cmp.mapping.confirm({ select = true }),
                    ["<C-e>"]   = cmp.mapping.abort(),
                }),
                sources = {
                    { name = "nvim_lsp" },
                },
            })
        end,
    },

    -- ─────────────────────────────────────────────
    -- Подсказки по клавишам (Which-key)
    -- ─────────────────────────────────────────────
    {
        "folke/which-key.nvim",
        config = function()
            local wk = require("which-key")
            wk.setup({})

            wk.add({
                { "<leader>w", ":w<CR>",                        desc = "💾 Сохранить файл" },
                { "<leader>q", ":q<CR>",                        desc = "❌ Выйти" },
                { "<leader>e", ":Neotree toggle<CR>",           desc = "📁 Файловое дерево" },
                { "<leader>s", ":wq<CR>",                       desc = "💾❌ Сохранить и выйти" },
                { "<leader>f", ":Telescope find_files<CR>",     desc = "🔍 Найти файл" },
                { "<leader>b", ":Telescope file_browser<CR>",   desc = "📁 Открыть папку" },
                { "<leader>g", ":Telescope live_grep<CR>",      desc = "🔍 Найти текст" },
                { "<leader>t", desc = "💻 Терминал" },
            })
        end,
    },

    -- ─────────────────────────────────────────────
    -- Иконки
    -- ─────────────────────────────────────────────
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },

    -- ─────────────────────────────────────────────
    -- Telescope + file-browser
    -- ─────────────────────────────────────────────
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
        },
        config = function()
            require("telescope").setup({})
            require("telescope").load_extension("file_browser")
        end,
    },

    -- ─────────────────────────────────────────────
    -- Терминал (ToggleTerm)
    -- ─────────────────────────────────────────────
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size         = 20,
                open_mapping = [[<c-\>]],
                direction    = "float",
                shell        = shell,
                float_opts   = { border = "rounded" },
            })

            vim.keymap.set("n", "<leader>t", function()
                local dir = vim.fn.expand("%:p:h")
                if dir == "" then
                    dir = vim.fn.getcwd()
                end
                require("toggleterm.terminal").Terminal:new({
                    dir        = dir,
                    direction  = "float",
                    shell      = shell,
                    float_opts = { border = "rounded" },
                }):toggle()
            end, { desc = "💻 Терминал в папке файла" })
        end,
    },

    -- ─────────────────────────────────────────────
    -- Авто-закрывающиеся скобки (Autopairs)
    -- ─────────────────────────────────────────────
    {
        "windwp/nvim-autopairs",
        event  = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,
            })
        end,
    },

    -- ─────────────────────────────────────────────
    -- Подсветка цветов (#hex, rgb())
    -- ─────────────────────────────────────────────
    {
        "brenoprata10/nvim-highlight-colors",
        lazy = false,
        config = function()
            require("nvim-highlight-colors").setup({
                render = "background",
            })
        end,
    },

    -- ─────────────────────────────────────────────
    -- Красивые отступы
    -- ─────────────────────────────────────────────
    {
        "lukas-reineke/indent-blankline.nvim",
        lazy = false,
        main = "ibl",
        config = function()
            require("ibl").setup({
                indent = { char = "│" },
                scope  = {
                    enabled    = true,
                    show_start = true,
                },
            })
        end,
    },
}