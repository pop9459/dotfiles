require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt ='both' -- to enable cursorline!
vim.opt.scrolloff = 8
vim.opt.wrap = false -- disable word wrap
vim.opt.textwidth = 120 -- to set preffered line length
vim.opt.colorcolumn = "+0" -- draw a line at textwidth
