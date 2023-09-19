require("core.options") -- load neovim settings

local keymaps = require("core.keymaps") -- keymap reference
keymaps.init() -- initialize and load general keymaps
keymaps.plugins() -- load plugin specific keymaps

require("core.lazy") -- load lazy nvim plugin manager
require("core.colorscheme") -- load color theme settings
require("core.autocmds") -- load auto commands
