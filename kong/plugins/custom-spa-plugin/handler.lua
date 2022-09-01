-- The access block of code has been moved to a separate file
local access = require "kong.plugins.custom-spa-plugin.access"
-- These configuration items are required by the plugin.
local CustomSpaPlugin = {
  PRIORITY = 0,
  VERSION  = "1.0.0",
}
-- Executed for every request from a client and before it is being proxied to the upstream service.
function CustomSpaPlugin:access(conf)
  -- Call our execute function in the access module.
  access.execute(conf)
end
-- Return the handler
return CustomSpaPlugin
