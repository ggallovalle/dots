--- Compact single-child directory chains in fyler (e.g. src/main/java/com/app).
--- Patches state.to_lines and select/visit via setup — no plugin source edits.

local M = {}

---@param state_mod table
---@param node table|nil
---@param path string
---@param hidden_items table
---@return table[]
local function visible_children(state_mod, node, path, hidden_items)
  local libfs = require("fyler.lib.fs")
  local libpath = require("fyler.lib.path")
  local out = {}

  if node and node.children then
    for _, child_node in pairs(node.children) do
      local data = state_mod.store[child_node.value]
      if data and not libfs.is_hidden(data.path, hidden_items) then
        out[#out + 1] = {
          name = data.name,
          path = data.path,
          type = data.type,
          node = child_node,
          id = data.id,
        }
      end
    end
    return out
  end

  local fs_path = libpath.to_os(path)
  local ok, err = pcall(function()
    for name, ftype in vim.fs.dir(fs_path) do
      local child_path = libpath.do_join(path, name)
      if ftype == "link" then
        local stat = vim.uv.fs_stat(libpath.to_os(child_path))
        ftype = stat and stat.type or "file"
      end
      if not libfs.is_hidden(child_path, hidden_items) then
        out[#out + 1] = {
          name = name,
          path = child_path,
          type = ftype,
        }
      end
    end
  end)
  if not ok and err then
    return out
  end

  return out
end

---@param state_mod table
---@param node table
---@return table[]
local function sorted_child_nodes(state_mod, node)
  local libfs = require("fyler.lib.fs")
  local children = vim.tbl_values(node.children or {})
  table.sort(children, function(a, b)
    if not a.value or not b.value then
      return false
    end
    return libfs.sort(state_mod.store[a.value], state_mod.store[b.value])
  end)
  return children
end

--- Build single-child chain starting at `start_node` / `start_data`.
---@param state_mod table
---@param start_node table
---@param start_data table
---@param hidden_items table
---@return { segments: string[], paths: string[], leaf_path: string, leaf_data: table, leaf_node: table }
local function chain_from(state_mod, start_node, start_data, hidden_items)
  local libpath = require("fyler.lib.path")
  local segments = { start_data.name }
  local paths = { start_data.path }
  local node = start_node
  local data = start_data

  while true do
    local kids = visible_children(state_mod, node, data.path, hidden_items)
    if #kids ~= 1 or kids[1].type ~= "directory" then
      break
    end

    local child = kids[1]
    segments[#segments + 1] = child.name
    paths[#paths + 1] = child.path

    if child.node then
      node = child.node
      data = state_mod.store[node.value]
    else
      local id = state_mod.store_path_id[libpath.to_key(child.path)]
      if not id then
        id = state_mod.store_register_fs_entry({
          name = child.name,
          path = child.path,
          type = "directory",
        })
      end
      data = state_mod.store[id]
      if node.children and node.children[child.name] then
        node = node.children[child.name]
      else
        node = { value = id }
      end
    end
  end

  return {
    segments = segments,
    paths = paths,
    leaf_path = paths[#paths],
    leaf_data = data,
    leaf_node = node,
  }
end

--- Paths from compact start through leaf (inclusive), walking upward from leaf.
---@param state_inst table
---@param leaf_path string
---@param hidden_items table
---@return string[]
local function chain_paths_to_leaf(state_inst, leaf_path, hidden_items)
  local libpath = require("fyler.lib.path")
  local state_mod = require("fyler.state")
  local paths = { leaf_path }
  local cur = leaf_path
  local root = state_inst.pseudo_root_path

  while true do
    local parent = libpath.to_dirname(cur)
    if not parent or parent == cur or parent == root or #parent < #root then
      break
    end

    -- Prefer tree node for parent when available; else FS.
    local parent_node = nil
    state_inst:walk(function(node)
      parent_node = node
    end, { target_path = parent })

    local kids = visible_children(state_mod, parent_node, parent, hidden_items)
    local only = kids[1]
    if #kids == 1 and only and only.type == "directory" and libpath.is_equal(only.path, cur) then
      table.insert(paths, 1, parent)
      cur = parent
    else
      break
    end
  end

  return paths
end

---@param state_inst table
---@param hidden_items table
---@return table[]
local function compact_to_lines(state_inst, hidden_items)
  local libpath = require("fyler.lib.path")
  local libfs = require("fyler.lib.fs")
  local state_mod = require("fyler.state")
  local result = {}

  local function emit_walk(node, depth)
    if not node.value then
      return
    end

    local data = state_mod.store[node.value]
    if not data then
      return
    end

    if depth > 0 and libfs.is_hidden(data.path, hidden_items) then
      return
    end

    if depth == 0 then
      if data.type == "directory" and state_inst.meta[libpath.to_key(data.path)] then
        for _, child in ipairs(sorted_child_nodes(state_mod, node)) do
          emit_walk(child, depth + 1)
        end
      end
      return
    end

    if data.type == "directory" then
      local chain = chain_from(state_mod, node, data, hidden_items)
      local leaf = chain.leaf_data
      local name = #chain.segments > 1 and table.concat(chain.segments, "/") or data.name
      local item = {
        id = leaf.id,
        path = leaf.path,
        name = name,
        type = "directory",
        depth = depth - 1,
        expanded = state_inst.meta[libpath.to_key(leaf.path)] or false,
      }
      result[#result + 1] = item

      if item.expanded and chain.leaf_node then
        for _, child in ipairs(sorted_child_nodes(state_mod, chain.leaf_node)) do
          emit_walk(child, depth + 1)
        end
      end
      return
    end

    result[#result + 1] = {
      id = data.id,
      path = data.path,
      name = data.name,
      type = data.type,
      depth = depth - 1,
    }
  end

  emit_walk(state_inst.root, 0)
  return result
end

---@param instance table
---@param args table|nil
function M.select(instance, args)
  args = args or {}
  local finder = require("fyler.finder")
  local libpath = require("fyler.lib.path")
  local state_mod = require("fyler.state")

  local node_data = finder.parse_cursor_line(instance)
  if not node_data then
    return
  end

  if node_data.type ~= "directory" then
    instance:select(args)
    return
  end

  local hidden = instance.cache.ui.hidden_items
  local leaf = node_data.path
  local chain = chain_paths_to_leaf(instance.state, leaf, hidden)
  local expanded = instance.state.meta[libpath.to_key(leaf)]

  if expanded then
    for i = #chain, 1, -1 do
      instance.state:toggle(chain[i], false)
    end
  else
    for _, path in ipairs(chain) do
      instance.state:toggle(path, true)
    end
  end

  instance:refresh({
    recursive = true,
    callback = function()
      local id = state_mod.store_path_id[libpath.to_key(leaf)]
      if id and instance._id_to_line then
        instance._view.lnum = instance._id_to_line[id] or 1
      end
    end,
  })
end

---@param instance table
---@param args table|nil
function M.visit(instance, args)
  args = args or {}

  if args.parent then
    instance:visit(args)
    return
  end

  if args.cursor then
    local finder = require("fyler.finder")
    local node_data = finder.parse_cursor_line(instance)
    if not (node_data and node_data.type == "directory") then
      return
    end
    -- Compact rows already use the leaf path as identity.
    instance:visit({ path = node_data.path })
    return
  end

  if args.path then
    local hidden = instance.cache.ui.hidden_items
    local state_mod = require("fyler.state")
    local libpath = require("fyler.lib.path")

    local node = nil
    instance.state:walk(function(n)
      node = n
    end, { target_path = args.path })

    local data = node and state_mod.store[node.value]
    if data and data.type == "directory" and node then
      local chain = chain_from(state_mod, node, data, hidden)
      instance:visit({ path = chain.leaf_path })
      return
    end

    -- Path may not be loaded yet — dive via FS from args.path.
    local stub = {
      value = state_mod.store_path_id[libpath.to_key(args.path)] or state_mod.store_register_fs_entry({
        name = vim.fs.basename(args.path),
        path = args.path,
        type = "directory",
      }),
    }
    local start_data = state_mod.store[stub.value]
    local chain = chain_from(state_mod, stub, start_data, hidden)
    instance:visit({ path = chain.leaf_path })
    return
  end

  instance:visit(args)
end

function M.install()
  local state_mod = require("fyler.state")
  if state_mod._kb_compact then
    return
  end

  local orig_new = state_mod.new
  state_mod.new = function(...)
    local st = orig_new(...)
    st.to_lines = function()
      local hidden = st._kb_hidden_items
        or {
          switches = {},
          patterns = {},
          always_visible = {},
          always_hidden = {},
        }
      return compact_to_lines(st, hidden)
    end
    return st
  end

  local finder = require("fyler.finder")
  local orig_get = finder.instance_get
  finder.instance_get = function(...)
    local inst = orig_get(...)
    if inst and not inst._kb_compact then
      inst._kb_compact = true
      inst.state._kb_hidden_items = inst.cache.ui.hidden_items

      -- Mutate builds id_to_path via state:walk over every expanded node. Compact
      -- rows omit intermediate chain members, so those IDs look "deleted".
      -- Restrict that walk to IDs that compact_to_lines actually renders.
      local orig_mutate = inst.mutate
      inst.mutate = function(self)
        local st = self.state
        local orig_walk = st.walk
        st.walk = function(_, callback, opts)
          opts = opts or {}
          if opts.skip_hidden then
            local hidden = opts.hidden_items or self.cache.ui.hidden_items
            local libfs = require("fyler.lib.fs")
            for _, item in ipairs(compact_to_lines(st, hidden)) do
              if not libfs.is_hidden(item.path, hidden) then
                callback({ value = item.id }, (item.depth or 0) + 1)
              end
            end
            return
          end
          return orig_walk(_, callback, opts)
        end

        local ok, err = pcall(orig_mutate, self)
        st.walk = orig_walk
        if not ok then
          error(err)
        end
      end
    end
    return inst
  end

  state_mod._kb_compact = true
end

return M
