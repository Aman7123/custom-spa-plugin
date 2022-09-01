-- For accessing Kong varibales during runtime.
local kong          = kong
local spa_helpers   = require "kong.plugins.custom-spa-plugin.spa_helpers"
-- A storage place for default HTML strings.
local defaultHtml   = "<!DOCTYPE html><html><body><h1>200 - Success</h1></body></html>"

-- This function is able to check if table contains a certain value and it not empty.
local function setContains(set, key)
  -- A userdata object is a reference to the uderlying C language.
  -- My investigation shows that the type is userdata when the user did not enter any value.
  -- Never seeing this type before? Read about it here: https://www.lua.org/pil/28.1.html
  return (set[key] ~= nil and type(set[key]) ~= "userdata" and set[key] ~= "")
end

-- Schema represents the required items to serve in the Admin GUI when configuring a plugin.
local schema = {
  -- The name is always defined by the parent folder name.
  name = "custom-spa-plugin",
  fields = {
    { config = {
        -- The 'config' record is the custom part of the plugin schema.
        type = "record",
        fields = {
          -- Each object within this level should be a uniquie variable item { variable_name = {} }
          { body = { 
              -- Each K/V pair within the variable name object should be variable property.
              -- All properties are under this part of the docs: 
              -- https://docs.konghq.com/gateway/2.8.x/plugin-development/plugin-configuration/#describing-your-configuration-schema
              type    = "string", 
              default = defaultHtml
            }
          },
          -- This value is used directly to append to each Content-Type header in every response.
          -- TODO: Replace this with the https://github.com/wbond/puremagic. 
          { content_type = { 
              type     = "string", 
              required = true,
              default  = "text/html"
            }
          },
          { file = { 
              type = "string", 
              -- Custom validator provides a way for creating custom functions to parse the data.
              custom_validator = spa_helpers.validate_path, 
            } 
          },
          { source = {
              -- When using a one_of property this allows the frontend to show a drop-down selection box.
              required = true,
              type     = "string",
              one_of   = { "body", "file" },
              default  = "body"
            }
          },
        },
      },
    },
  },
  -- This part of the object is used by the validation when clicking the create or update button.
  entity_checks = {
    { custom_entity_check = {
        field_sources = { "config" },
        -- This function is called when the user clicks the create or update button.
        -- entity = {"config":{"body":"string","file":"string","source":"string"}}
        fn = function(entity)
          -- config = {"body":"string","file":"string","source":"string"}
          local config = entity.config
          -- file = "string" | null
          local file   = config.file
          -- body = "string" | null
          local body   = config.body
          -- source = "string"
          local source = config.source
          -- When the user selected the file drop-down option.
          if (source == "file") then
            -- Validate the portal is enabled.
            if not spa_helpers.is_portal_enabled_and_workspace_activated() then
              return nil, "The portal is not enabled in the configuration or in the workspace"
            end
            -- Ensure some string is written in the file field.
            if (not setContains(config, "file")) then
              return nil, "The file field must be set when the source is " .. spa_helpers.escape_text("file")
            end
            -- Query the database to ensure the file exist.
            local finalFileObj, err = spa_helpers.get_file_by_path(file)
            if not finalFileObj then
              -- For a non-existant file that does not mean an error occurred, if so return to user here.
              if err then 
                return nil, err
              end
              -- Since no file was found, return to user here.
              return nil, "The file " .. spa_helpers.escape_text(file) .. " does not exist"
            end
          end
          -- When the user selected the body drop-down option.
          if (source == "body" and not setContains(config, "body")) then
            -- Returns a red error box to the Admin UI or HTTP response in the API.
            return nil, "The body field must be set when the source is " .. spa_helpers.escape_text("body")
          end
          -- If nothing has returned nil already, when the config is valid.
          return true
        end
      }
    }
  },
}

return schema