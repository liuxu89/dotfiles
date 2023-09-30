-- vim.opt.list = true
vim.opt.listchars:append "space:⋅"
-- vim.opt.listchars:append "eol:↴"

require("ibl").setup {
    indent = {
        char = '│',
        -- char = '⎸',
        highlight = highlights,
    },
    show_end_of_line = false,
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}
