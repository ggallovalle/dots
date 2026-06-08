local process = require("std.process")
local logger = require("std.logger")

---@class kbplugin.luarocks.UserConfig
---@field dependencies string[]

---@class kbplugin.luarocks.Health
---@field configured        boolean
---@field lua_version       string
---@field dependencies      string[]
---@field install_ok        boolean
---@field install_running   boolean
---@field install_error     string?
---@field wired_path_count  integer
---@field wired_cpath_count integer
---@field state_dir         string
---@field rockspec_path     string

local M = {}

local State = {
  data = {
    configured = false,
    lua_version = "5.1",
    dependencies = {},
    install_ok = false,
    install_running = false,
    install_error = nil,
    wired_path_count = 0,
    wired_cpath_count = 0,
    state_dir = vim.fn.stdpath("state") .. "/kbplugin/luarocks",
    rockspec_path = ""
  }
}

local Log = logger.new({
  path = vim.fn.stdpath("state") .. "/kbplugin/luarocks.log"
})

local Config = {}

---@param dependencies unknown
---@return string[]|nil, string|nil
function Config.validate_dependencies(dependencies)
  if type(dependencies) ~= "table" then
    return nil, "dependencies must be an array of strings"
  end
  local out = {}
  for i, dep in ipairs(dependencies) do
    if type(dep) ~= "string" then
      return nil, ("dependencies[%d] must be a string"):format(i)
    end
    local trimmed = vim.trim(dep)
    if trimmed == "" then
      return nil, ("dependencies[%d] is empty"):format(i)
    end
    out[#out + 1] = trimmed
  end
  return out, nil
end

local Runtime = {}

---@param path_var string
---@param fragment string
---@return boolean, string?
function Runtime.prepend_unique(path_var, fragment)
  if fragment == nil or fragment == "" then
    return false, nil
  end
  local escaped = fragment:gsub("([^%w])", "%%%1")
  if path_var:find(escaped, 1, false) then
    return false, nil
  end
  if path_var == "" then
    return true, fragment
  end
  return true, fragment .. ";" .. path_var
end

---@param luarocks    string
---@param lua_version string
---@param cb          fun(ok: boolean, err: string?)
function Runtime.wire_paths(luarocks, lua_version, cb)
  local path_cmd = {
    luarocks, "--lua-version", lua_version, "path", "--lr-path"
  }
  local cpath_cmd = {
    luarocks, "--lua-version", lua_version, "path", "--lr-cpath"
  }

  process.execute_text(process.make(path_cmd[1], vim.list_slice(path_cmd, 2)), function (
    err, path_result
  )
    if err ~= nil or path_result == nil or path_result.code ~= 0 then
      cb(false, "failed to read luarocks path: "
        .. vim.trim((path_result and path_result.stderr) or tostring(err or "")))
      return
    end

    process.execute_text(
      process.make(cpath_cmd[1], vim.list_slice(cpath_cmd, 2)),
      function (err2, cpath_result)
        if err2 ~= nil or cpath_result == nil or cpath_result.code ~= 0 then
          cb(false, "failed to read luarocks cpath: "
            .. vim.trim((cpath_result and cpath_result.stderr)
              or tostring(err2 or "")))
          return
        end

        local wired_path_count = 0
        local wired_cpath_count = 0

        for _, p in ipairs(vim.split(
          vim.trim(path_result.stdout or ""),
          ";",
          {
            trimempty = true
          }
        )) do
          local changed, value = Runtime.prepend_unique(package.path, p)
          if changed and value ~= nil then
            package.path = value
            wired_path_count = wired_path_count + 1
          end
        end

        for _, p in ipairs(vim.split(vim.trim(cpath_result.stdout or ""), ";", {
          trimempty = true
        })) do
          local changed, value = Runtime.prepend_unique(package.cpath, p)
          if changed and value ~= nil then
            package.cpath = value
            wired_cpath_count = wired_cpath_count + 1
          end
        end

        State.data.wired_path_count = wired_path_count
        State.data.wired_cpath_count = wired_cpath_count
        cb(true, nil)
      end
    )
  end)
end

local Installer = {}

---@param deps string[]
---@return string
function Installer.write_temp_rockspec(deps)
  vim.fn.mkdir(State.data.state_dir, "p")
  local rockspec_path = State.data.state_dir .. "/kbplugin-deps-1.0-1.rockspec"
  local lines = {
    'package = "kbplugin-deps"', 'rockspec_format = "3.0"', 'version = "1.0-1"',
    "source = {", '   url = "file:///tmp/kbplugin-deps.tar.gz",', "}",
    "dependencies = {", '   "lua >= 5.1, < 5.6",'
  }
  for _, dep in ipairs(deps) do
    lines[#lines + 1] = ("   %q,"):format(dep)
  end
  lines[#lines + 1] = "}"
  lines[#lines + 1] = 'build = { type = "none" }'
  vim.fn.writefile(lines, rockspec_path)
  State.data.rockspec_path = rockspec_path
  return rockspec_path
end

---@param argv string[]
---@return string
function Installer.shell_join(argv)
  return table.concat(argv, " ")
end

---@param argv string[]
---@param cb   fun(ok: boolean, err: string?)
function Installer.run(argv, cb)
  ---@diagnostic disable-next-line: param-type-mismatch
  local cmd = process.make(argv[1], vim.list_slice(argv, 2))
  process.execute_text(cmd, function (err, result)
    if err ~= nil or result == nil then
      cb(false, tostring(err or "transport error"))
      return
    end
    if result.code ~= 0 then
      local msg = vim.trim((result.stderr or "") ~= "" and result.stderr
        or (result.stdout or ""))
      cb(false, msg)
      return
    end
    cb(true, nil)
  end)
end

---@param opts? kbplugin.luarocks.UserConfig
function M.setup(opts)
  ---@diagnostic disable-next-line: assign-type-mismatch
  opts = opts or {}
  local dependencies, err = Config.validate_dependencies(opts.dependencies or {})
  if err ~= nil then
    State.data.install_ok = false
    State.data.install_error = err
    vim.notify("kbplugin.luarocks: " .. err, vim.log.levels.ERROR)
    return
  end

  local luarocks = vim.fn.exepath("luarocks")
  if luarocks == "" then
    State.data.install_ok = false
    State.data.install_error = "luarocks executable not found"
    vim.notify(
      "kbplugin.luarocks: luarocks executable not found",
      vim
        .log
        .levels
        .ERROR
    )
    return
  end

  State.data.configured = true
  State.data.dependencies = dependencies

  ---@diagnostic disable-next-line: unnecessary-if
  if State.data.install_running then
    Log:warn("setup called while install already running")
    return
  end
  State.data.install_running = true

  ---@diagnostic disable-next-line: param-type-mismatch
  local rockspec_path = Installer.write_temp_rockspec(dependencies)
  local install_cmd = {
    luarocks, "--lua-version", State.data.lua_version, "--local", "install",
    "--only-deps", rockspec_path
  }

  Log:info("install dependencies", {
    lua_version = State.data.lua_version,
    dependencies = dependencies,
    cmd = Installer.shell_join(install_cmd)
  })

  local function finish_error(msg)
    State.data.install_running = false
    State.data.install_ok = false
    State.data.install_error = msg
    Log:error("install failed", { error = msg })
    vim.notify("kbplugin.luarocks install failed: " .. msg, vim.log.levels.ERROR)
  end

  local function finish_success()
    State.data.install_running = false
    State.data.install_ok = true
    State.data.install_error = nil
    Log:info("setup complete", {
      wired_path_count = State.data.wired_path_count,
      wired_cpath_count = State.data.wired_cpath_count
    })
  end

  Installer.run(install_cmd, function (ok, install_err)
    if not ok then
      finish_error(install_err or "unknown install error")
      return
    end
    Runtime.wire_paths(luarocks, State.data.lua_version, function (
      wired_ok, wire_err
    )
      if not wired_ok then
        finish_error(wire_err or "path wiring failed")
        return
      end
      finish_success()
    end)
  end)
end

---@return kbplugin.luarocks.Health
function M.health()
  return vim.deepcopy(State.data)
end

---@return std.logger.Instance
function M.logger()
  return Log
end

return M
