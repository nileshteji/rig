local custom_gruvbox = require'lualine.themes.gruvbox'

-- Change the background of lualine_c section for normal mode
custom_gruvbox.normal.c.bg = '#112233'

local function git_blame()
  local blame = vim.b.gitsigns_blame_line
  if blame then
    return blame
  end
  return ''
end

require('lualine').setup {
  options = { theme  = custom_gruvbox },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {
      {'filename', path = 1},
      {git_blame},
    },
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
}
