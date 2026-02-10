local core = require('lib/core')

--- NVIDIA internal host resolver for computelab/ptyche/prenyx/lyris clusters.
-- @param callback (function) Called with list of available hosts from all clusters.
local function nvidia_internal_hosts(callback)
  local cluster_commands = {
    '/usr/bin/env fish -c computelab_sc_nodes',
    '/usr/bin/env fish -c computelab_nodes',
    '/usr/bin/env fish -c ptyche_nodes',
    '/usr/bin/env fish -c prenyx_nodes',
    '/usr/bin/env fish -c lyris_nodes',
  }

  core.lua_systemlist_async_all(cluster_commands, callback)
end

--- NVIDIA clusters preset with per-cluster base paths and users.
-- Each cluster has: hosts (function/table), base_path, user
local nvidia_clusters = {
  computelab = {
    hosts = function(cb)
      core.lua_systemlist_async('/usr/bin/env fish -c computelab_nodes', cb)
    end,
    base_path = '/home/scratch.viraatc_sw_1',
    user = 'viraatc',
  },
  computelab_sc = {
    hosts = function(cb)
      core.lua_systemlist_async('/usr/bin/env fish -c computelab_sc_nodes', cb)
    end,
    base_path = '/home/scratch.viraatc_sw_1',
    user = 'viraatc',
  },
  lyris = {
    hosts = function(cb)
      core.lua_systemlist_async('/usr/bin/env fish -c lyris_nodes', cb)
    end,
    base_path = '/project/coreai_mlperf_inference/viraatc',
    user = 'viraatc-mfa',
  },
  ptyche = {
    hosts = function(cb)
      core.lua_systemlist_async('/usr/bin/env fish -c ptyche_nodes', cb)
    end,
    base_path = '/lustre/fsw/coreai_mlperf_inference/viraatc',
    user = 'viraatc-mfa',
  },
  prenyx = {
    hosts = function(cb)
      core.lua_systemlist_async('/usr/bin/env fish -c prenyx_nodes', cb)
    end,
    base_path = '/lustre/fsw/coreai_mlperf_inference/viraatc',
    user = 'viraatc-mfa',
  },
}

return {
  nvidia_internal_hosts = nvidia_internal_hosts,
  nvidia_clusters = nvidia_clusters,
}
