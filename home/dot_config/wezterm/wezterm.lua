local wezterm = require 'wezterm'

local config = {}

config.font = wezterm.font_with_fallback {
  'GeistMono Nerd Font',
  'JetBrains Mono',
  'Noto Sans Mono',
}
config.font_size = 14
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1', 'dlig=1' }

config.window_decorations = "RESIZE"
config.window_background_opacity = 1.0
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.window_padding = {
  bottom = "1cell",
}

config.default_cursor_style = "SteadyUnderline"
config.cursor_thickness = 2
config.animation_fps = 1
config.cursor_blink_rate = 0

config.colors = {
  foreground = "#CDD6F4",
  background = "#1E1E2E",

  cursor_bg = "#F5E0DC",
  cursor_border = "#F5E0DC",
  cursor_fg = "#1E1E2E",

  selection_bg = "#45475A",
  selection_fg = "#CDD6F4",

  ansi = {
    "#45475A",
    "#F38BA8",
    "#A6E3A1",
    "#F9E2AF",
    "#89B4FA",
    "#CBA6F7",
    "#94E2D5",
    "#BAC2DE",
  },
  brights = {
    "#585B70",
    "#F38BA8",
    "#A6E3A1",
    "#F9E2AF",
    "#89B4FA",
    "#CBA6F7",
    "#94E2D5",
    "#A6ADC8",
  },
}

config.colors.tab_bar = {
  background = "#1E1E2E",
  active_tab = {
    bg_color = "#313244",
    fg_color = "#CDD6F4",
  },
  inactive_tab = {
    bg_color = "#1E1E2E",
    fg_color = "#585B70",
  },
  inactive_tab_hover = {
    bg_color = "#313244",
    fg_color = "#CDD6F4",
  },
  new_tab = {
    bg_color = "#1E1E2E",
    fg_color = "#585B70",
  },
  new_tab_hover = {
    bg_color = "#313244",
    fg_color = "#CDD6F4",
  },
}

local master = "CTRL|SHIFT"

-- https://wezterm.org/config/default-keys.html
config.keys = {
  { key = 'Tab', mods = 'ALT',       action = wezterm.action.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'SHIFT|ALT', action = wezterm.action.ActivateTabRelative(-1) },
  { key = '1',   mods = 'ALT',       action = wezterm.action.ActivateTab(0) },
  { key = '2',   mods = 'ALT',       action = wezterm.action.ActivateTab(1) },
  { key = '3',   mods = 'ALT',       action = wezterm.action.ActivateTab(2) },
  { key = '4',   mods = 'ALT',       action = wezterm.action.ActivateTab(3) },
  { key = '5',   mods = 'ALT',       action = wezterm.action.ActivateTab(4) },
  { key = '6',   mods = 'ALT',       action = wezterm.action.ActivateTab(5) },
  { key = '7',   mods = 'ALT',       action = wezterm.action.ActivateTab(6) },
  { key = '8',   mods = 'ALT',       action = wezterm.action.ActivateTab(7) },
  { key = '9',   mods = 'ALT',       action = wezterm.action.ActivateTab(8) },
  { key = 't',   mods = 'ALT',       action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w',   mods = master,      action = wezterm.action.CloseCurrentTab { confirm = false } },
  {
    key = 'd',
    mods = master,
    action = wezterm.action.SpawnCommandInNewWindow {
      args = { 'codex' },
    },
  },
}

-- config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
-- config.tab_bar_at_bottom = true
-- config.show_tab_index_in_tab_bar = true

config.max_fps = 120
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

config.scrollback_lines = 10000
config.term = "xterm-256color"

return config
