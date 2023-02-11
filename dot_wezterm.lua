local wezterm = require 'wezterm'

local config = {
   -- window_decorations = "RESIZE",
   color_scheme = "Monokai Remastered",
}

-- launch menu settings
local launch_menu = {}

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = 'pwsh'
  table.insert(launch_menu, {
    label = 'PowerShell',
    args = { 'powershell.exe', '-NoLogo' },
  })

  table.insert(launch_menu, {
    label = 'PSCore',
    args = { 'pwsh.exe', '-NoLogo' },
  })
end

config.launch_men = launch_menu

return config
