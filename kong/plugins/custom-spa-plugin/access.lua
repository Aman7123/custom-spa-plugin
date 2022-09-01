local kong             = kong
local spa_helpers      = require "kong.plugins.custom-spa-plugin.spa_helpers"

-- Defines this file as a module.
local _M = {}

-- Add our custom module finctions to the module table.
function _M.execute(conf)
  local source = conf.source
  local ct     = conf.content_type
  if (source == "body") then
    return spa_helpers.success_exit(conf.body, ct)
  end
  if (source == "file") then
    -- These next 2 lines of code correlate to the Kong Cache
    -- More information can be found here: https://docs.konghq.com/gateway/2.8.x/plugin-development/entities-cache/
    -- Be sure to checkout the custom lookup function in spa_helpers.load_file_by_key
    local file_cache_key = kong.db.files:cache_key(conf.file)
    local file, err = kong.cache:get(file_cache_key, {ttl= 60}, -- Use 1 min refresh
                                  spa_helpers.load_file_by_key, file_cache_key)
    return spa_helpers.success_exit(file.contents, ct)
  end
end

-- Return this module.
return _M