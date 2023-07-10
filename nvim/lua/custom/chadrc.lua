---@type ChadrcConfig 
 local M = {}
 M.ui = {
  theme = 'tokyonight',
  border = 'rounded',
  transparency = true
 }
 M.plugins = "custom.plugins"
 M.mappings = require "custom.mappings"
 return M
