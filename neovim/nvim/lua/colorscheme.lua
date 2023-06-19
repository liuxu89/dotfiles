-- define your colorscheme here
local colorscheme = 'monokai_pro'
local colorscheme = 'one'

-- local colorscheme = 'stellarized-light'

require('monokai').setup { italics = false }

local is_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not is_ok then
    vim.notify('colorscheme ' .. colorscheme .. ' not found!')
    return
end

vim.cmd.highlight({ "Normal", "guibg=NONE" })
vim.cmd.highlight({ "Normal", "ctermbg=NONE" })
vim.cmd.highlight({ "LineNr", "guibg=NONE" })
vim.cmd.highlight({ "LineNr", "ctermbg=NONE" })
vim.cmd.highlight({ "SignColumn", "ctermbg=NONE" })
vim.cmd.highlight({ "SignColumn", "guibg=NONE" })

vim.cmd.highlight({ "CursorLineNr", "guibg=green" })
vim.cmd.highlight({ "CursorLineNr", "ctermbg=green" })
vim.cmd.highlight({ "CursorLine", "guibg=NONE" }) 
vim.cmd.highlight({ "CursorLine", "ctermbg=NONE" })
