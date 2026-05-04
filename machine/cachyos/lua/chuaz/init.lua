
---@meta chuaz




---@class chuaz.Version
---@field semver chuaz.Semver Version information (semver + metadata)
---@field version string Full version string (e.g., "1.2.3-beta.1+build123")
---@field commit string Git commit hash
---@field date string Build date (YYYY-MM-DD)
---@field built_by string Build system (e.g., "goreleaser")
---@field message string Commit message
local Version = {}

---@class chuaz.Semver
---@field major integer Major version number
---@field minor integer Minor version number
---@field patch integer Patch version number
---@field pre_release string Pre-release identifier (e.g., "beta.1")
---@field metadata string Build metadata (e.g., "build123")
local Semver = {}




---@class chuaz.chuaz
---@field version chuaz.Version Version information for this chezmoi build
---@field config_dir string Path to the chezmoi configuration directory
---@field config_file string Path to the chezmoi configuration file
---@field source_dir string Path to the chezmoi source directory
---@field data table<string, any> Template data (live property)
local chuaz = {}

return chuaz
