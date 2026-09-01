--- Hide gitignored paths in fyler without patching the plugin.
--- Uses Neogit git APIs (`neogit.lib.git`) for ignore discovery.

local M = {}

---@type boolean
local hide_ignored = true

---@type table<string, string|false>
local root_cache = {}

---@type table<string, { set: table<string, true>, at: number }>
local ignored_cache = {}

local CACHE_TTL_MS = 2000

---@return table|nil
local function neogit_git()
  local ok, git = pcall(require, "neogit.lib.git")
  if ok then
    return git
  end
  return nil
end

---@param path string
---@return string|nil
local function repo_root(path)
  local cached = root_cache[path]
  if cached ~= nil then
    return cached or nil
  end

  local git = neogit_git()
  if not git then
    root_cache[path] = false
    return nil
  end

  local dir = vim.fs.dirname(path)
  if not git.cli.is_inside_worktree(dir) then
    root_cache[path] = false
    return nil
  end

  local root = vim.fs.normalize(git.cli.worktree_root(dir))
  if not root or root == "" then
    root_cache[path] = false
    return nil
  end

  root_cache[path] = root
  return root
end

---@param root string
---@param force boolean|nil
---@return table<string, true>
local function ignored_set(root, force)
  local now = vim.uv.hrtime() / 1e6
  local entry = ignored_cache[root]
  if not force and entry and (now - entry.at) < CACHE_TTL_MS then
    return entry.set
  end

  local set = {}
  local git = neogit_git()
  if git then
    -- Pin Neogit's active repo so cli calls use this worktree as cwd.
    require("neogit.lib.git.repository").instance(root)

    local result = git.cli["ls-files"].others.exclude_standard
      .args("--ignored", "--directory")
      .call({ hidden = true, await = true, ignore_error = true })

    for _, rel in ipairs(result.stdout or {}) do
      rel = rel:gsub("/$", "")
      if #rel > 0 then
        set[vim.fs.normalize(vim.fs.joinpath(root, rel))] = true
      end
    end
  end

  ignored_cache[root] = { set = set, at = now }
  return set
end

---@param path string
---@return boolean
local function is_gitignored(path)
  path = vim.fs.normalize(path)
  local root = repo_root(path)
  if not root then
    return false
  end

  local set = ignored_set(root)
  local cur = path
  while #cur >= #root do
    if set[cur] then
      return true
    end
    local parent = vim.fs.dirname(cur)
    if parent == cur then
      break
    end
    cur = parent
  end

  return false
end

function M.invalidate()
  ignored_cache = {}
  root_cache = {}
end

---@return boolean
function M.enabled()
  return hide_ignored
end

---@param instance table|nil
function M.toggle(instance)
  hide_ignored = not hide_ignored
  M.invalidate()
  vim.notify(
    hide_ignored and "Fyler: hiding gitignored" or "Fyler: showing gitignored",
    vim.log.levels.INFO,
    { title = "Fyler" }
  )
  if instance and instance.refresh then
    instance:refresh()
  end
end

--- Patch fyler.lib.fs.is_hidden once plugin modules are loadable.
function M.install()
  local fs = require("fyler.lib.fs")
  if fs._kb_hide_ignored then
    return
  end

  local original = fs.is_hidden
  fs.is_hidden = function(path, hidden_items)
    if original(path, hidden_items) then
      return true
    end
    if hide_ignored and is_gitignored(path) then
      return true
    end
    return false
  end
  fs._kb_hide_ignored = true
end

return M
