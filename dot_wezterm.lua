local wezterm = require 'wezterm'

local config = {
  -- window_decorations = "RESIZE",
  color_scheme = "Monokai Remastered",
  font = wezterm.font_with_fallback {
    'MesloLGS NF',
    'IBM Plex Mono',
  },
  font_size = 13,
  initial_cols = 120,
  initial_rows = 30,
}

local launch_menu = {}

-- mac
if wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin' then
  config.font_size = 13
end

-- windows
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  -- Wezterm become blinking when using WebGpu in VM
  config.front_end = 'Software'
  config.font_size = 12
  config.default_prog = {'pwsh'}
  table.insert(launch_menu, {
    label = 'PowerShell',
    args = { 'powershell.exe', '-NoLogo' },
  })

  table.insert(launch_menu, {
    label = 'PSCore',
    args = { 'pwsh.exe', '-NoLogo' },
  })
end

config.launch_menu = launch_menu

return config
