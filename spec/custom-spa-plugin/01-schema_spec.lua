local PLUGIN_NAME         = "custom-spa-plugin"
local cjson               = require "cjson"
local workspaces          = require "kong.workspaces"
local schema              = require "kong.db.schema"
local ngx_log             = ngx.log
local WARN                = ngx.WARN
local ce_helpers          = require "spec.helpers"
local portal_example_uuid = "123e4567-e89b-12d3-a456-426614174000"
local portal_example_path = "spec/example.yaml"
local defaultHtml         = "<!DOCTYPE html><html><body><h1>200 - Success</h1></body></html>"

-- helper function to validate data against a schema
local validate do
  local validate_entity = ce_helpers.validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end

-- Mock return of external dependency being used for validating wsdl uuid. custom-wsdl-dao helpers.   
local function portal_mock(en_portal, load_point)
  _G.kong = {
    test_point = load_point,
    -- Mock kong.default_workspace and set to our example UUID
    default_workspace = portal_example_uuid,
    -- Mock the Kong Database
    db = {
      workspaces = {
        select = function()
          return {
            id = portal_example_uuid,
            config = {
              portal = en_portal,
              portal_developer_meta_fields = "[{\"label\":\"Full Name\",\"title\":\"full_name\",\"validator\":{\"required\":true,\"type\":\"string\"}}]"
            },
            name = "default"
          }
        end
      },
      files = {
        each = function()
          return {
            id = portal_example_uuid,
            path = portal_example_path,
            content = defaultHtml
          }
        end,
        select = function()
          return {
            id = portal_example_uuid,
            path = portal_example_path,
            content = defaultHtml,
            workspace_id = portal_example_uuid,
            created_at = os.time()
          }
        end,
        select_by_path = function()
          return {
            id = portal_example_uuid,
            path = portal_example_path,
            content = defaultHtml,
            workspace_id = portal_example_uuid,
            created_at = os.time()
          }
        end
      }
    }
  }

  return schema.new(require("kong.plugins."..PLUGIN_NAME..".schema"))
end

local function return_conf_wrapper(conf)
  return {
    config = conf
  }
end

local function streql(a, b)
  return (a == b)
end

local err_msgs = {
  ["not_enabled"] = "The portal is not enabled in the configuration or in the workspace",
  ["no_file_provided"] = "The file field must be set when the source is \"file\"",
  ["pg_path_err"] = "[postgres] path must not begin with a slash '/'",
  ["not_found"] = "The file \"spec/example.yaml\" does not exist"
}

describe(PLUGIN_NAME .. ": (schema)", function()
  ngx_log(WARN, cjson.encode(kong.version))
  ngx_log(WARN, cjson.encode(kong.version_num))
  -- Nothing configured, allowed because of defaults 
  it("Nothing configured, allowed because of defaults", function()
    local ok, err = validate({})
    
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  -- In-line "body" selected, body manually deleted 
  it("In-line body selected, body manually deleted", function()
    local ok, err = validate({
        body = ""
    })
    
    assert.is_nil(ok)
    assert.is_truthy(err)
  end)

  -- Selecting the "file" option, portal disabled in workspace 
  it("Selecting the file option, portal disabled in workspace", function()
    local ok, err = portal_mock(false):validate(return_conf_wrapper({
        source = "file"
    }))
    
    print(cjson.encode(err))
    assert.is_nil(ok)
    assert.is_truthy(err)
    assert(streql(err_msgs["not_enabled"], err["@entity"][1]))
  end)

  -- Selecting the "file" option, file not provided
  it("Selecting the file option, file not provided", function()
    local ok, err = portal_mock(true):validate(return_conf_wrapper({
        source = "file"
    }))
    
    print(cjson.encode(err))
    assert.is_nil(ok)
    assert.is_truthy(err)
    assert(streql(err_msgs["no_file_provided"], err["@entity"][1]))
  end)

  -- Selecting the "file" option, file name not valid
  it("Selecting the file option, file name not valid", function()
    local ok, err = portal_mock(true):validate(return_conf_wrapper({
        file   = "//tmp/test.txt",
        source = "file"
    }))
    
    print(cjson.encode(err))
    assert.is_nil(ok)
    assert.is_truthy(err)
    assert(streql(err_msgs["pg_path_err"], err["@entity"][1]))
  end)

  -- Selecting the "file" option, file not found
  -- it("Selecting the file option, file not found", function()
  --   local ok, err = portal_mock(true):validate(return_conf_wrapper({
  --       file   = portal_example_path,
  --       source = "file"
  --   }))
    
  --   print(cjson.encode(err))
  --   assert.is_truthy(err)
  --   assert(streql(err_msgs["not_found"], err["@entity"][1]))
  -- end)

  -- Selecting the "file" option, file valid
  -- it("Selecting the file option, file valid", function()
  --   local ok, err = portal_mock(true):validate(return_conf_wrapper({
  --       file   = portal_example_path,
  --       source = "file"
  --   }))
    
  --   print(cjson.encode(err))
  --   assert.is_nil(err)
  --   assert.is_truthy(ok)
  -- end)
end)