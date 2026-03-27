require("nilesh.set")
require("nilesh.remap")
require("nilesh.lazy")

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Strip trailing whitespace on save (mitchellh)
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local save = vim.fn.winsaveview()
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.winrestview(save)
    end,
})

-- Prevent automatic folding
vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*",
    command = "set nofoldenable",
})
