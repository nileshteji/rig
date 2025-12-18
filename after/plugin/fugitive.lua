vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- Global merge conflict resolution keymaps
vim.keymap.set("n", "<leader>gh", "<cmd>diffget //2<CR>")          -- get from HEAD (left)
vim.keymap.set("n", "<leader>gm", "<cmd>diffget //3<CR>")          -- get from merge branch (right)
vim.keymap.set("n", "<leader>gc", "<cmd>Git add .<CR><cmd>Git commit<CR>") -- add all and commit

local ThePrimeagen_Fugitive = vim.api.nvim_create_augroup("ThePrimeagen_Fugitive", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufWinEnter", {
    group = ThePrimeagen_Fugitive,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "fugitive" then
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = {buffer = bufnr, remap = false}
        vim.keymap.set("n", "<leader>p", function()
            vim.cmd.Git('push')
        end, opts)

        -- rebase always
        vim.keymap.set("n", "<leader>P", function()
            vim.cmd.Git({'pull',  '--rebase'})
        end, opts)

        -- NOTE: It allows me to easily set the branch i am pushing and any tracking
        -- needed if i did not set the branch up correctly
        vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts);

        -- Merge conflict resolution keymaps
        vim.keymap.set("n", "<leader>gj", "<cmd>diffget //3<CR>", opts) -- get from right (target branch)
        vim.keymap.set("n", "<leader>gf", "<cmd>diffget //2<CR>", opts) -- get from left (current branch)
        vim.keymap.set("n", "<leader>gs", "<cmd>Gwrite<CR>", opts)      -- stage the current file
    end,
})
