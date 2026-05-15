local M = {}

local LEVELS = { debug = 1, info = 2, warn = 3, error = 4 }

---@alias std.logger.Level "debug"|"info"|"warn"|"error"

---@class std.logger.Config
---@field path string
---@field max_bytes? integer
---@field level? std.logger.Level

---@class std.logger.Event
---@field op string
---@field level std.logger.Level
---@field data table
---@field set? fun(self: std.logger.Event, ctx: table?): std.logger.Event
---@field set_level? fun(self: std.logger.Event, level: std.logger.Level): std.logger.Event
---@field emit? fun(self: std.logger.Event, msg?: string)

---@class std.logger.Instance
---@field _path string
---@field set_level? fun(self: std.logger.Instance, level: std.logger.Level)
---@field get_level? fun(self: std.logger.Instance): std.logger.Level
---@field debug? fun(self: std.logger.Instance, msg: string, ctx?: table)
---@field info? fun(self: std.logger.Instance, msg: string, ctx?: table)
---@field warn? fun(self: std.logger.Instance, msg: string, ctx?: table)
---@field error? fun(self: std.logger.Instance, msg: string, ctx?: table)
---@field event? fun(self: std.logger.Instance, op: string, base?: table): std.logger.Event

---@class std.logger.HealthOptions
---@field title? string
---@field tail? integer

---@class std.logger.Explorer
---@field path? fun(self: std.logger.Explorer): string
---@field exists? fun(self: std.logger.Explorer): boolean
---@field size_bytes? fun(self: std.logger.Explorer): integer?
---@field read_all? fun(self: std.logger.Explorer): string[]
---@field tail? fun(self: std.logger.Explorer, n: integer): string[]
---@field health? fun(self: std.logger.Explorer, sink: fun(line: string): nil, opts?: std.logger.HealthOptions): nil

local function encode_ctx(ctx)
  if ctx == nil then
    return ""
  end
  local ok, json = pcall(vim.json.encode, ctx)
  if ok and json then
    return " " .. json
  end
  return " {\"ctx\":\"encode_error\"}"
end

local function trim_file(path, max_bytes)
  local stat = vim.uv.fs_stat(path)
  if stat == nil or stat.size <= max_bytes then
    return
  end
  vim.fn.writefile({}, path)
end

local function append_line(path, line, max_bytes)
  local dir = vim.fs.dirname(path)
  vim.schedule(function()
    vim.fn.mkdir(dir, "p")
    trim_file(path, max_bytes)
    vim.fn.writefile({ line }, path, "a")
  end)
end

---@param level string
---@param min_level string
local function allow_level(level, min_level)
  return (LEVELS[level] or 99) >= (LEVELS[min_level] or LEVELS.info)
end

---@param cfg std.logger.Config
---@return std.logger.Instance
function M.new(cfg)
  local path = cfg.path
  local max_bytes = cfg.max_bytes or 1024 * 1024
  local min_level = cfg.level or "info"

  ---@type std.logger.Instance
  local logger = {}
  logger._path = path

  ---@param level std.logger.Level
  ---@param msg string
  ---@param ctx table?
  local function write(level, msg, ctx)
    if not allow_level(level, min_level) then
      return
    end
    local ts = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local line = string.format("%s %s %s%s", ts, level:upper(), msg, encode_ctx(ctx))
    append_line(path, line, max_bytes)
  end

  ---@param level std.logger.Level
  function logger.set_level(_, level)
    min_level = level
  end

  function logger.get_level()
    return min_level
  end

  function logger.debug(_, msg, ctx)
    write("debug", msg, ctx)
  end

  function logger.info(_, msg, ctx)
    write("info", msg, ctx)
  end

  function logger.warn(_, msg, ctx)
    write("warn", msg, ctx)
  end

  function logger.error(_, msg, ctx)
    write("error", msg, ctx)
  end

  ---@param op string
  ---@param base table?
  ---@return std.logger.Event
  function logger.event(_, op, base)
    ---@type std.logger.Event
    local e = {
      op = op,
      level = "info",
      data = vim.deepcopy(base or {})
    }

    function e:set(ctx)
      self.data = vim.tbl_deep_extend("force", self.data, ctx or {})
      return self
    end

    function e:set_level(level)
      self.level = level
      return self
    end

    function e:emit(msg)
      write(self.level, msg or self.op, vim.tbl_deep_extend("force", { op = self.op }, self.data))
    end

    return e
  end

  return logger
end

---@param instance std.logger.Instance
---@return std.logger.Explorer
function M.explorer(instance)
  local path = instance and instance._path
  if type(path) ~= "string" or path == "" then
    error("logger.explorer requires a logger instance from logger.new")
  end

  ---@type std.logger.Explorer
  local explorer = {}

  function explorer.path()
    return path
  end

  function explorer.exists()
    return vim.uv.fs_stat(path) ~= nil
  end

  function explorer.size_bytes()
    local stat = vim.uv.fs_stat(path)
    if stat == nil then
      return nil
    end
    return stat.size
  end

  function explorer.read_all()
    if not explorer.exists() then
      return {}
    end
    return vim.fn.readfile(path)
  end

  function explorer.tail(_, n)
    local lines = explorer.read_all()
    if n == nil or n <= 0 then
      return {}
    end
    local count = #lines
    local start_idx = math.max(1, count - n + 1)
    local out = {}
    for i = start_idx, count do
      out[#out + 1] = lines[i]
    end
    return out
  end

  ---@param sink fun(line: string): nil
  ---@param opts? std.logger.HealthOptions
  function explorer:health(sink, opts)
    local title = (opts and opts.title) or "log"
    local tail_count = (opts and opts.tail) or 10

    if not self:exists() then
      sink(title .. " file: not created yet")
      return
    end

    sink(title .. " file: " .. self:path())
    local lines = self:tail(tail_count)
    if #lines == 0 then
      sink("last logs: (empty)")
      return
    end

    sink("last " .. tostring(tail_count) .. " log lines:")
    for _, line in ipairs(lines) do
      sink(line)
    end
  end

  return explorer
end

local default_logger = nil

function M.default()
  if default_logger ~= nil then
    return default_logger
  end
  default_logger = M.new({
    path = vim.fn.stdpath("state") .. "/kbplugins/default.log"
  })
  return default_logger
end

return M
