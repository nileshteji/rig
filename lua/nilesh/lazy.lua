local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Telescope
    {
        'nvim-telescope/telescope.nvim',
        tag = 'v0.2.0',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
            vim.keymap.set('n', '<C-p>', builtin.git_files, {})
            vim.keymap.set('n', '<leader>ps', function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end)
            vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
        end
    },

    -- Colorschemes
    {
        'rose-pine/neovim',
        name = 'rose-pine',
    },
    {
        'ellisonleao/gruvbox.nvim',
        priority = 1000,
        config = function()
            require('gruvbox').setup({
                undercurl = true,
                underline = true,
                bold = false,
                italic = {
                    strings = true,
                    emphasis = true,
                    comments = true,
                    operators = false,
                    folds = true,
                },
                strikethrough = true,
                invert_selection = false,
                invert_signs = false,
                invert_tabline = false,
                invert_intend_guides = false,
                inverse = true,
                contrast = "hard",
                palette_overrides = {},
                overrides = {},
                dim_inactive = false,
                transparent_mode = true,
            })
            vim.cmd.colorscheme("gruvbox")
        end
    },
    { 'folke/tokyonight.nvim' },

    -- Trouble
    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup { icons = false }
        end
    },

    -- Treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter').setup {
                ensure_installed = { "kotlin", "swift", "java", "vimdoc", "javascript", "typescript" },
                sync_install = false,
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            }
        end
    },
    { 'nvim-treesitter/nvim-treesitter-context' },

    -- Harpoon
    {
        'theprimeagen/harpoon',
        config = function()
            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")
            vim.keymap.set("n", "<leader>a", mark.add_file)
            vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)
            vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end)
            vim.keymap.set("n", "<C-t>", function() ui.nav_file(2) end)
            vim.keymap.set("n", "<C-n>", function() ui.nav_file(3) end)
            vim.keymap.set("n", "<C-s>", function() ui.nav_file(4) end)
        end
    },

    { 'theprimeagen/refactoring.nvim' },

    -- Undotree
    {
        'mbbill/undotree',
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },

    -- Fugitive
    {
        'tpope/vim-fugitive',
        config = function()
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
            vim.keymap.set("n", "<leader>gh", "<cmd>diffget //2<CR>")
            vim.keymap.set("n", "<leader>gm", "<cmd>diffget //3<CR>")
            vim.keymap.set("n", "<leader>gc", "<cmd>Git add .<CR><cmd>Git commit<CR>")

            local ThePrimeagen_Fugitive = vim.api.nvim_create_augroup("ThePrimeagen_Fugitive", {})
            vim.api.nvim_create_autocmd("BufWinEnter", {
                group = ThePrimeagen_Fugitive,
                pattern = "*",
                callback = function()
                    if vim.bo.ft ~= "fugitive" then
                        return
                    end
                    local bufnr = vim.api.nvim_get_current_buf()
                    local opts = { buffer = bufnr, remap = false }
                    vim.keymap.set("n", "<leader>p", function()
                        vim.cmd.Git('push')
                    end, opts)
                    vim.keymap.set("n", "<leader>P", function()
                        vim.cmd.Git({ 'pull', '--rebase' })
                    end, opts)
                    vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts)
                    vim.keymap.set("n", "<leader>gj", "<cmd>diffget //3<CR>", opts)
                    vim.keymap.set("n", "<leader>gf", "<cmd>diffget //2<CR>", opts)
                    vim.keymap.set("n", "<leader>gs", "<cmd>Gwrite<CR>", opts)
                end,
            })
        end
    },

    -- Gitsigns
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup {
                current_line_blame = true,
                current_line_blame_opts = {
                    delay = 200,
                    virt_text_pos = 'eol',
                },
                current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
            }
        end
    },

    -- Mason (LSP installer)
    {
        'williamboman/mason.nvim',
        config = function()
            require('mason').setup()
        end
    },
    {
        'williamboman/mason-lspconfig.nvim',
        dependencies = { 'williamboman/mason.nvim' },
        config = function()
            require('mason-lspconfig').setup({
                ensure_installed = {
                    'kotlin_language_server',
                    'rust_analyzer',
                    'lua_ls',
                },
            })
        end
    },

    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lua',
            'saadparwaiz1/cmp_luasnip',
            'L3MON4D3/LuaSnip',
            'rafamadriz/friendly-snippets',
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            require('luasnip.loaders.from_vscode').lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'nvim_lua' },
                }, {
                    { name = 'buffer' },
                    { name = 'path' },
                }),
            })
        end
    },

    -- LSP config (native Neovim 0.11+)
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason-lspconfig.nvim',
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local bufnr = args.buf
                    local opts = { buffer = bufnr, remap = false }

                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
                    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
                    vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
                    vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
                    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
                    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
                end,
            })

            vim.lsp.config('*', {
                capabilities = capabilities,
            })

            vim.lsp.enable('kotlin_language_server')
            vim.lsp.enable('rust_analyzer')
            vim.lsp.enable('lua_ls')

            vim.diagnostic.config({
                virtual_text = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = 'E',
                        [vim.diagnostic.severity.WARN] = 'W',
                        [vim.diagnostic.severity.HINT] = 'H',
                        [vim.diagnostic.severity.INFO] = 'I',
                    },
                },
            })
        end
    },

    -- Indent blankline
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            require("ibl").setup()
        end
    },

    { "folke/zen-mode.nvim" },
    { "github/copilot.vim" },
    { "eandrju/cellular-automaton.nvim" },
    { "laytan/cloak.nvim" },

    -- Cursorline
    {
        'yamatsum/nvim-cursorline',
        config = function()
            vim.opt.cursorline = true
            vim.api.nvim_set_hl(0, "CursorLine", { underline = true, sp = "#00ffff", bg = "NONE" })
            vim.g.cursorline_timeout = 200
            vim.g.cursorline_number = true
        end
    },

    -- Lualine
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons', 'lewis6991/gitsigns.nvim' },
        config = function()
            local custom_gruvbox = require 'lualine.themes.gruvbox'
            custom_gruvbox.normal.c.bg = '#112233'

            local function git_blame()
                local blame = vim.b.gitsigns_blame_line
                if blame then
                    return blame
                end
                return ''
            end

            require('lualine').setup {
                options = { theme = custom_gruvbox },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = {
                        { 'filename', path = 1 },
                        { git_blame },
                    },
                    lualine_x = { 'encoding', 'fileformat', 'filetype' },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                },
            }
        end
    },
})
