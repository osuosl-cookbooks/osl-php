# osl\_php\_apc

This resource is used to install APC from the PECL channel. Not compatible with EL >= 8.

## Actions

* `:install` - Default action. Installs APC and creates an ini file with the specified configuration.

## Properties

|  Name   |  Type  |  Default                  |  Description                      |  Required?  |
| :------ | :----: | :-----------------------: | :-------------------------------- | :---------- |
| options | Hash   | `osl_php_apc_conf` helper | Configuration to add to ini file. | true        |
