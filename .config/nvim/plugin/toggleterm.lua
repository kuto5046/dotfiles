require("toggleterm").setup{
  open_mapping = [[<leader>t]],
  direction = 'float',
  highlights = {
    FloatBorder = { guifg = '#719cd6'},
  },
  float_opts = {
    border = 'curved',
    height = 20,
  },
}
