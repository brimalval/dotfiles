---@type ChadrcConfig 
 local M = {}
 M.ui = {
  theme = 'penumbra_dark',
  border = 'rounded',
  transparency = true,

  -- add colors as needed
  changed_themes = {
    chadracula = {
      base_30 = {
        one_bg2 = "#505050"
      },
      base_16 = {
      }
    }
  }
 }
 M.plugins = "custom.plugins"
 M.mappings = require "custom.mappings"
 return M
