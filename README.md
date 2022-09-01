# Custom SPA (Single Page App) Plugin
* Name: custom-spa-plugin
* Version: 1.0.0
* Kong Version: 2.8.x

The most up-to-date code can be found in the `develop` branch.

## Description
Currently this plugin is able to use a Kong service as a webserver.

### Parameters
Here's a list of all the parameters which can be used in this plugin's configuration:

| Form Parameter | default | description |
|----------------|---------|-------------|
| `name`|| The name of the plugin to use, in this case: `custom-soap-validation`.|
| `enabled` | `true` | Whether this plugin will be applied.|
| `config.document` || Raw text representing an HTML file.|

## Installation
Please install this plugin as directed by the Kong Custom Plugin [Installation Guide](https://docs.konghq.com/enterprise/2.4.x/plugin-development/distribution/)

All requirements for this parent plugin apply including PostgreSQL as the primary Kong database.

## Testing
This develop branch edition does not have up-to-date tests!

## Additional modules
* This plugin includes tests for use with [`kong-pongo`](https://github.com/Kong/kong-pongo)

## Contact
* Aaron Renner: aaron.renner@argano.com

