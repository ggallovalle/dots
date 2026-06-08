-- see: ~/.local/share/nvim/lazy/typst-preview.nvim/lua/typst-preview/config.lua
--
---@class kbinit.typst.Config
---@field dependencies_bin table<string, string | nil>
---@field open_cmd         string

-- see: ~/.local/share/nvim/lazy/nvim-surround/lua/nvim-surround/annotations.lua

---@class kbinit.surround.Config
---@field surrounds?    table<string, false | user_surround>
---@field aliases?      table<string, false | string | string[]>
---@field highlight?    { duration: false | integer }
---@field move_cursor?  false | "begin" | "sticky"
---@field indent_lines? false | function

--- see: ~/.local/share/nvim/lazy/nvim-autopairs/lua/nvim-autopairs.lua

---@class kbinit.autopairs.Config

