-- define your colorscheme here
local colorscheme = 'monokai_pro'

-- local colorscheme = 'stellarized-light'

require('monokai').setup { italics = false }

local is_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not is_ok then
    vim.notify('colorscheme ' .. colorscheme .. ' not found!')
    return
end

require('monokai').setup { italics = false }
