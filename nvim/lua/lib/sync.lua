local class = require('lib/class')

-- SyncTarget class for lazy host resolution and lsyncd config generation
local SyncTarget = class()

--- Initialize a new SyncTarget instance.
-- @param opts Table containing sync target options.
-- @field opts.host (string|function|table) Hostname, resolver function, or list of hosts.
-- @field opts.user (string) The user on the remote target.
-- @field opts.path (string) The base path on the remote target.
-- @field opts.use_worktrees (boolean) If true, append worktree name (last component of PWD) to paths.
-- @field opts.work_subdir (string) Optional subdirectory to sync within the project.
-- @field opts.excludes (table) List of paths to exclude from sync.
function SyncTarget:init(opts)
  opts = opts or {}
  assert(opts.host, 'host cannot be nil')
  assert(opts.user, 'user cannot be nil')
  assert(opts.path, 'path cannot be nil')

  self.host = opts.host
  self.user = opts.user
  self.path = opts.path:gsub('/$', '') -- normalize: remove trailing slash
  self.use_worktrees = opts.use_worktrees or false
  self.work_subdir = opts.work_subdir and opts.work_subdir:gsub('^/', ''):gsub('/$', '') or nil
  self.excludes = opts.excludes or {}
  self._resolved_host = nil
end

--- Lazy host resolution with optional interactive selection.
-- @param force_select (boolean) Force re-selection even if host is cached.
-- @param callback (function) Callback with resolved host (for async selection).
-- @return (string|nil) The resolved host, or nil if pending async selection.
function SyncTarget:resolve_host(force_select, callback)
  -- Return cached host if available and not forcing re-select
  if self._resolved_host and not force_select then
    if callback then callback(self._resolved_host) end
    return self._resolved_host
  end

  -- Helper to process hosts list and call callback
  local function process_hosts(hosts)
    -- Filter out nil/empty entries
    hosts = vim.tbl_filter(function(h) return h and h ~= '' end, hosts)

    if #hosts == 0 then
      if callback then callback(nil) end
      return nil
    elseif #hosts == 1 then
      self._resolved_host = hosts[1]
      if callback then callback(self._resolved_host) end
      return self._resolved_host
    else
      -- Multiple hosts - prompt user to select
      vim.ui.select(hosts, { prompt = 'Select remote host> ' }, function(choice)
        if choice then
          self._resolved_host = choice
        end
        if callback then callback(self._resolved_host) end
      end)
      return nil -- Async selection pending
    end
  end

  -- Determine available hosts
  if type(self.host) == 'function' then
    -- Check if host function accepts a callback (async) by checking arity
    -- Pass callback for async execution to avoid blocking UI
    self.host(function(hosts)
      process_hosts(hosts or {})
    end)
    return nil -- Async pending
  elseif type(self.host) == 'table' then
    return process_hosts(self.host)
  else
    -- Single string host
    self._resolved_host = self.host
    if callback then callback(self._resolved_host) end
    return self._resolved_host
  end
end

--- Compute actual source and target paths based on configuration.
-- @param source_path (string) Base local source path.
-- @return (string, string) Actual source path, actual target path.
function SyncTarget:_compute_paths(source_path)
  source_path = source_path:gsub('/$', '') -- normalize
  local actual_source = source_path
  local actual_target = self.path

  -- Append worktree name if configured (last component of source_path)
  if self.use_worktrees then
    local worktree = source_path:match('/([^/]+)$')
    if worktree then
      actual_target = actual_target .. '/' .. worktree
    end
  end

  -- Append work_subdir if configured
  if self.work_subdir then
    actual_source = actual_source .. '/' .. self.work_subdir
    actual_target = actual_target .. '/' .. self.work_subdir
  end

  return actual_source, actual_target
end

--- Format excludes list for lsyncd config.
-- @param excludes (table) List of exclude patterns.
-- @return (string) Formatted excludes string.
function SyncTarget:_format_excludes(excludes)
  if not excludes or #excludes == 0 then return '' end
  local quoted = vim.tbl_map(function(e) return string.format("'%s'", e) end, excludes)
  return table.concat(quoted, ', ')
end

--- Generate lsyncd config string.
-- @param source_path (string) Local source path to sync from.
-- @param opts (table) Additional options.
-- @field opts.extra_excludes (table) Additional excludes to merge.
-- @field opts.compress (boolean) Enable rsync compression.
-- @return (string|nil) lsyncd config string, or nil if host not resolved.
function SyncTarget:lsyncd_config(source_path, opts)
  opts = opts or {}

  if not self._resolved_host then
    return nil
  end

  local actual_source, actual_target = self:_compute_paths(source_path)
  local excludes = vim.list_extend(vim.deepcopy(self.excludes), opts.extra_excludes or {})

  return string.format([[
-- vim: ft=lua
settings {
  logfile = '/tmp/lsyncd.log',
  statusFile = '/tmp/lsyncd.status',
  nodaemon = true
}

sync {
  default.rsyncssh,
  source = "%s",
  targetdir = "%s",
  host = "%s",
  exclude = { %s },
  rsync = {
    whole_file = true,
    archive = true,
    compress = %s
  }
}
]], actual_source, actual_target, self._resolved_host,
    self:_format_excludes(excludes), opts.compress and "true" or "false")
end

--- Get SSH connection string.
-- @return (string|nil) SSH connection string (user@host), or nil if not resolved.
function SyncTarget:ssh_string()
  if not self._resolved_host then return nil end
  return string.format('%s@%s', self.user, self._resolved_host)
end

--- Get resolved host.
-- @return (string|nil) The resolved host, or nil if not yet resolved.
function SyncTarget:get_host()
  return self._resolved_host
end

--- Factory function to create a SyncTarget.
-- @param opts (table) Options passed to SyncTarget:init().
-- @return (SyncTarget) New SyncTarget instance.
local function target(opts)
  return SyncTarget.new(opts)
end

-- ClusterTarget class for multi-cluster sync with automatic path resolution
local ClusterTarget = class()

--- Initialize a new ClusterTarget instance.
-- @param opts Table containing cluster target options.
-- @field opts.clusters (table) Cluster configurations (e.g., Project.presets.nvidia_clusters).
-- @field opts.project_subdir (string) Project subdirectory relative to cluster base paths.
-- @field opts.use_worktrees (boolean) If true, append worktree name to paths.
-- @field opts.work_subdir (string) Optional subdirectory to sync within the project.
-- @field opts.excludes (table) List of paths to exclude from sync.
function ClusterTarget:init(opts)
  opts = opts or {}
  assert(opts.clusters, 'clusters cannot be nil')
  assert(opts.project_subdir, 'project_subdir cannot be nil')

  self.clusters = opts.clusters
  self.project_subdir = opts.project_subdir:gsub('^/', ''):gsub('/$', '') -- normalize
  self.use_worktrees = opts.use_worktrees or false
  self.work_subdir = opts.work_subdir and opts.work_subdir:gsub('^/', ''):gsub('/$', '') or nil
  self.excludes = opts.excludes or {}
  self._resolved_cluster = nil -- cluster config object
  self._resolved_cluster_name = nil
  self._resolved_host = nil
end

--- Lazy host resolution with optional interactive selection across all clusters.
-- @param force_select (boolean) Force re-selection even if host is cached.
-- @param callback (function) Callback with resolved host (for async selection).
-- @return (string|nil) The resolved host, or nil if pending async selection.
function ClusterTarget:resolve_host(force_select, callback)
  -- Return cached host if available and not forcing re-select
  if self._resolved_host and not force_select then
    if callback then callback(self._resolved_host) end
    return self._resolved_host
  end

  -- Show loading indicator
  vim.notify('Fetching hosts from clusters...', vim.log.levels.INFO)

  local cluster_names = vim.tbl_keys(self.clusters)
  local pending = #cluster_names
  local all_hosts = {} -- { {host=..., cluster_name=..., cluster_config=...}, ... }

  -- Fetch hosts from all clusters in parallel
  for _, cluster_name in ipairs(cluster_names) do
    local cluster = self.clusters[cluster_name]
    local hosts_source = cluster.hosts

    local function on_hosts(hosts)
      hosts = hosts or {}
      for _, host in ipairs(hosts) do
        if host and host ~= '' then
          table.insert(all_hosts, {
            host = host,
            cluster_name = cluster_name,
            cluster_config = cluster,
          })
        end
      end
      pending = pending - 1

      if pending == 0 then
        -- All clusters have responded
        self:_select_from_hosts(all_hosts, callback)
      end
    end

    if type(hosts_source) == 'function' then
      hosts_source(on_hosts)
    elseif type(hosts_source) == 'table' then
      on_hosts(hosts_source)
    elseif type(hosts_source) == 'string' then
      on_hosts({ hosts_source })
    else
      on_hosts({})
    end
  end

  return nil -- Async pending
end

--- Internal: Select from aggregated hosts list.
-- @param all_hosts (table) List of {host, cluster_name, cluster_config}.
-- @param callback (function) Callback with resolved host.
function ClusterTarget:_select_from_hosts(all_hosts, callback)
  if #all_hosts == 0 then
    if callback then callback(nil) end
    return
  end

  -- Sort by cluster name then host for consistent ordering
  table.sort(all_hosts, function(a, b)
    if a.cluster_name == b.cluster_name then
      return a.host < b.host
    end
    return a.cluster_name < b.cluster_name
  end)

  if #all_hosts == 1 then
    local entry = all_hosts[1]
    self._resolved_host = entry.host
    self._resolved_cluster = entry.cluster_config
    self._resolved_cluster_name = entry.cluster_name
    if callback then callback(self._resolved_host) end
    return
  end

  -- Build display items with cluster prefix
  local display_items = {}
  local entry_map = {}
  for _, entry in ipairs(all_hosts) do
    local display = string.format('[%s] %s', entry.cluster_name, entry.host)
    table.insert(display_items, display)
    entry_map[display] = entry
  end

  vim.ui.select(display_items, { prompt = 'Select remote host> ' }, function(choice)
    if choice then
      local entry = entry_map[choice]
      self._resolved_host = entry.host
      self._resolved_cluster = entry.cluster_config
      self._resolved_cluster_name = entry.cluster_name
    end
    if callback then callback(self._resolved_host) end
  end)
end

--- Get the user for the resolved cluster.
-- @return (string|nil) The user, or nil if not resolved.
function ClusterTarget:get_user()
  if not self._resolved_cluster then return nil end
  return self._resolved_cluster.user
end

--- Get the full target path (base_path + project_subdir).
-- @return (string|nil) The full path, or nil if not resolved.
function ClusterTarget:get_path()
  if not self._resolved_cluster then return nil end
  return self._resolved_cluster.base_path .. '/' .. self.project_subdir
end

--- Compute actual source and target paths based on configuration.
-- @param source_path (string) Base local source path.
-- @return (string, string) Actual source path, actual target path.
function ClusterTarget:_compute_paths(source_path)
  source_path = source_path:gsub('/$', '') -- normalize
  local actual_source = source_path
  local actual_target = self:get_path()

  -- Append worktree name if configured (last component of source_path)
  if self.use_worktrees then
    local worktree = source_path:match('/([^/]+)$')
    if worktree then
      actual_target = actual_target .. '/' .. worktree
    end
  end

  -- Append work_subdir if configured
  if self.work_subdir then
    actual_source = actual_source .. '/' .. self.work_subdir
    actual_target = actual_target .. '/' .. self.work_subdir
  end

  return actual_source, actual_target
end

--- Format excludes list for lsyncd config.
-- @param excludes (table) List of exclude patterns.
-- @return (string) Formatted excludes string.
function ClusterTarget:_format_excludes(excludes)
  if not excludes or #excludes == 0 then return '' end
  local quoted = vim.tbl_map(function(e) return string.format("'%s'", e) end, excludes)
  return table.concat(quoted, ', ')
end

--- Generate lsyncd config string.
-- @param source_path (string) Local source path to sync from.
-- @param opts (table) Additional options.
-- @field opts.extra_excludes (table) Additional excludes to merge.
-- @field opts.compress (boolean) Enable rsync compression.
-- @return (string|nil) lsyncd config string, or nil if host not resolved.
function ClusterTarget:lsyncd_config(source_path, opts)
  opts = opts or {}

  if not self._resolved_host or not self._resolved_cluster then
    return nil
  end

  local actual_source, actual_target = self:_compute_paths(source_path)
  local excludes = vim.list_extend(vim.deepcopy(self.excludes), opts.extra_excludes or {})

  return string.format([[
-- vim: ft=lua
settings {
  logfile = '/tmp/lsyncd.log',
  statusFile = '/tmp/lsyncd.status',
  nodaemon = true
}

sync {
  default.rsyncssh,
  source = "%s",
  targetdir = "%s",
  host = "%s",
  exclude = { %s },
  rsync = {
    whole_file = true,
    archive = true,
    compress = %s
  }
}
]], actual_source, actual_target, self:ssh_string(),
    self:_format_excludes(excludes), opts.compress and "true" or "false")
end

--- Get SSH connection string.
-- @return (string|nil) SSH connection string (user@host), or nil if not resolved.
function ClusterTarget:ssh_string()
  if not self._resolved_host or not self._resolved_cluster then return nil end
  return string.format('%s@%s', self._resolved_cluster.user, self._resolved_host)
end

--- Get resolved host.
-- @return (string|nil) The resolved host, or nil if not yet resolved.
function ClusterTarget:get_host()
  return self._resolved_host
end

--- Get resolved cluster name.
-- @return (string|nil) The resolved cluster name, or nil if not yet resolved.
function ClusterTarget:get_cluster_name()
  return self._resolved_cluster_name
end

--- Factory function to create a ClusterTarget.
-- @param opts (table) Options passed to ClusterTarget:init().
-- @return (ClusterTarget) New ClusterTarget instance.
local function cluster_target(opts)
  return ClusterTarget.new(opts)
end

return {
  SyncTarget = SyncTarget,
  ClusterTarget = ClusterTarget,
  target = target,
  cluster_target = cluster_target,
}
