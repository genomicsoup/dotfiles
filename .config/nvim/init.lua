-- file: init.lua
-- desc: nvim configuration.

-- Set the leader key.
-- Needs to be done before plugin load.
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- [[ package manager setup ]]

-- Install lazy, a package manager for nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
-- Our home directory
local homepath = vim.fn.expand('$HOME')

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end

vim.opt.rtp:prepend(lazypath)

-- [[ set up plugins ]] --

require('lazy').setup({

    -- auto close bracken/parens characters
    'windwp/nvim-autopairs',

    -- theme
    'rmehri01/onenord.nvim',

    {
        'slugbyte/lackluster.nvim',
        lazy = false,
    },

    -- copilot shit
    'github/copilot.vim',

    -- LSP configuration
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            { 'j-hui/fidget.nvim', opts = {}, branch = 'legacy' },
            'folke/neodev.nvim'
        }
    },

    -- Code formatting
    {
        'jose-elias-alvarez/null-ls.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim'
        }
    },

    -- lualine status line
    {
        'nvim-lualine/lualine.nvim',
        opts = {
            options = {
                icons_enabled = false,
                theme = 'onenord',
                component_separators = '|',
                section_separators = '',
            }
        }
    },

    -- Autocomplete
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip'
        }
    },

    -- Fuzzy finding
    {
        'nvim-telescope/telescope.nvim',
        version = '*',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },

    -- Improves sorting performance
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
            return vim.fn.executable 'make' == 1
        end,
    },

    -- Highlight, edit, and navigate code
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        config = function()
            pcall(require('nvim-treesitter.install').update { with_sync = true })
        end,
    },

    -- File explorer shit
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v2.x',
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        }
    },

    -- Zettelkasten and note taking
    {
        'renerocksai/telekasten.nvim',
        dependencies = {
            'nvim-telescope/telescope.nvim'
        }
    },

    -- Calendar view
    {
        'mattn/calendar-vim',
        dependencies = {
        }
    }
}, {})

-- [[ setup calls ]] --

-- theme setup
local lackluster = require('lackluster')
local lc = lackluster.color

--lackluster.setup({
--    tweak_syntax = {
--        type = lc.green,
--        builtin = lc.green,
--        keyword = lc.green,
--        string = 'default',
--    }
--})

vim.cmd.colorscheme('lackluster-mint')

local note_home = vim.fn.expand("$HOME/notes")

-- Note taking
require('telekasten').setup({
    -- home for all the notes
    home = note_home,
    -- subdirectories for certain kinds of notes
    dailies = note_home .. '/' .. 'daily',
    templates = note_home .. '/' .. 'daily',
    -- following links to nonexistent notes creates them
    follow_creates_nonexisting = true,
    dailies_create_nonexisting = true,
    -- daily note template
    template_new_daily = note_home .. '/' .. 'templates/daily.md',
    -- how tags are defined, other options: :tag: and yaml-bare
    tag_notation = "#tag",
    -- create [[subdir/title]] links instead of [[title]] links
    subdirs_in_links = true,
    template_handling = "smart",
    new_note_location = "smart",
    rename_update_links = true
})

--require('github/copilot.vim').setup()
--vim.g.copilot_no_tabe_map = true
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true

vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

-- File explorer
require('nvim-web-devicons').setup({
    default = true,
})
require('neo-tree').setup()

-- auto bracket pairs
require('nvim-autopairs').setup()

--require('onenord').setup({
--    theme = 'dark',
--    disable = {
--        background = true,
--        cursorline = false,
--    }
--})

-- LSP settings.

local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            -- apply whatever logic you want (in this example, we'll only use null-ls)
            return client.name == "null-ls"
        end,
        bufnr = bufnr,
    })
end

--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
    if client.supports_method('textDocument/formatting') then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                vim.lsp.buf.format({ bufnr = bufnr })
                --vim.lsp.buf.formatting_sync()
                --vim.lsp.buf.format()
                --lsp_formatting(bufnr)
            end,
        })
    end

    if vim.lsp.inlay_hint then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    -- Telescope mappings
    nmap('ff', require('telescope.builtin').find_files, '[F]ind [F]ile')
    nmap('fg', require('telescope.builtin').live_grep, '[F]ind [G]rep')

    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

require('neodev').setup()

-- code formatting setup
local null_ls = require('null-ls')

null_ls.setup({
    debug = true,
    on_attach = on_attach,
    sources = {
        -- python black formatter
        null_ls.builtins.formatting.black.with({
            extra_args = { '--line-length=100' }
        }),
        -- python isort formatter
        null_ls.builtins.formatting.isort,
        -- rustfmt formatter
        null_ls.builtins.formatting.rustfmt.with({
            extra_args = { '--edition=2021' }
        }),
    }
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

-- treesitter configuration
-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    --ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'help', 'vim' },
    ensure_installed = { 'lua', 'python', 'rust', 'tsx', 'typescript', 'vim' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true, disable = { 'python' } },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer',
            },
            goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer',
            },
            goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer',
            },
            goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer',
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
                ['<leader>A'] = '@parameter.inner',
            },
        },
    },
}


-- autocomplete setup which can utilize LPS features
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

require('mason').setup()
local mason_lspconfig = require 'mason-lspconfig'

-- Language servers that will be installed automatically
local servers = {
    -- deno
    --denols = {

    --},
    -- lua lang server
    lua_ls = {
        workspace = {
            checkThirdParty = false,
            library = {
                vim.env.RUNTIME
            }
        },
        runtime = {
            version = 'LuaJIT'
        },
        telemetry = { enable = false },
    },
    -- python
    pyright = {
        pyright = {
            openFilesOnly = true,
            useLibraryCodeForTypes = true,
        },
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                typeCheckingMode = 'off',
            },
        },
    },
    -- markdown
    marksman = {},
    -- rust
    rust_analyzer = {
        checkOnSave = {
            command = 'clippy',
        },
        diagnostics = {
            enable = true,
        },
        imports = {
            granularity = {
                group = 'module',
            },
            prefix = 'self',
        },
        cargo = {
            buildScripts = {
                enable = true,
            },
        },
        procMacro = {
            enable = true,
        },
        inlayHints = {
            enable = true,
            typeHints = true,
            chainingHints = true,
            parameterHints = true,
            otherHints = true,
        },
    }
}

mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers)
}

mason_lspconfig.setup_handlers {
    function(server_name)
        require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
        }
    end,
}

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

luasnip.config.setup {}

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-l>'] = cmp.mapping.select_next_item(),
        ['<C-s>'] = cmp.mapping.select_prev_item(),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'buffer' },
    }),
})
-- [[ vim options ]] --

-- Syntax highlight is on
vim.o.syntax = 'on'

-- Line numbers are on
vim.o.number = true

-- Relative sine numbers are on
vim.o.relativenumber = true

-- Defaults to case insensitive search
vim.o.ignorecase = true

-- Case sensitive search depending on the given pattern
vim.o.smartcase = true

-- Don't highlight search results
vim.o.hlsearch = false

-- Insert spaces on tab
vim.o.expandtab = true
vim.o.smarttab = true

-- Number of columns used for indents
vim.o.shiftwidth = 4

-- Number of columns used for tabs
vim.o.tabstop = 4

-- Auto indent based on indentation from previous line
vim.o.autoindent = true

-- Insert indentation in certain cases
vim.o.smartindent = true

-- Column + row numbers in the status line
vim.o.ruler = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 800

-- Save undo history
vim.o.undofile = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync vim+OS clipboard
vim.o.clipboard = 'unnamedplus'

-- Dark background
--vim.o.background = 'dark'

vim.o.termguicolors = true
vim.o.completeopt = 'menu,menuone,noselect'
vim.o.copyindent = true

-- Cursor updates
vim.o.guicursor = 'i-ci-ve:ver50-Cursor'

-- Highlights text on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- Restores the cursor position after closing a file
vim.api.nvim_create_autocmd('BufRead', {
    callback = function(opts)
        vim.api.nvim_create_autocmd('BufWinEnter', {
            once = true,
            buffer = opts.buf,
            callback = function()
                local ft = vim.bo[opts.buf].filetype
                local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
                if
                    not (ft:match('commit') and ft:match('rebase'))
                    and last_known_line > 1
                    and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
                then
                    vim.api.nvim_feedkeys([[g`"]], 'x', false)
                end
            end,
        })
    end,
})
