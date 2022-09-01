package = "custom-spa-plugin"

local pluginName = "custom-spa-plugin"
version = "1.0.0-1"

supported_platforms = {"linux", "macosx"}
source = {
  url = "https://bitbucket.org/mountainstatesoftware/custom-spa-plugin",
  tag = "1.0.0"
}

description = {
  summary = "Kong is a scalable and customizable API Management Layer built on top of Nginx.",
  homepage = "http://getkong.org",
  license = "Apache 2.0",
  maintainer = "Aaron Renner <aaron.renner@argano.com>"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".spa_helpers"] = "kong/plugins/"..pluginName.."/spa_helpers.lua",
    ["kong.plugins."..pluginName..".access"] = "kong/plugins/"..pluginName.."/access.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua"
  }
}